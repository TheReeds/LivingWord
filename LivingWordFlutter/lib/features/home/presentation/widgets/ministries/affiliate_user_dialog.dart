import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../providers/ministry_provider.dart';
import '../../../data/models/user_complete_model.dart';

class AffiliateUserDialog extends StatefulWidget {
  final UserCompleteModel user;

  const AffiliateUserDialog({
    super.key,
    required this.user,
  });

  @override
  State<AffiliateUserDialog> createState() => _AffiliateUserDialogState();
}

class _AffiliateUserDialogState extends State<AffiliateUserDialog> {
  String? selectedMinistry;
  bool isLoading = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    selectedMinistry = widget.user.ministry;
  }

  Future<void> _saveAffiliation(BuildContext context) async {
    if (!hasChanges) {
      Navigator.pop(context);
      return;
    }

    final ministryProvider = context.read<MinistryProvider>();
    final authProvider = context.read<AuthProvider>();
    final ministries = ministryProvider.ministries;

    setState(() => isLoading = true);

    try {
      if (selectedMinistry != widget.user.ministry) {
        // Si selectedMinistry es null (No ministry), usamos ID 0
        final ministryId = selectedMinistry == null
            ? 0
            : ministries.firstWhere(
              (ministry) => ministry.name == selectedMinistry,
          orElse: () => ministries.first,
        ).id;

        await ministryProvider.affiliateUser(
          ministryId: ministryId,
          userId: widget.user.id,
        );

        // Reload user data after successful affiliation
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await authProvider.loadUsers();
        });

        if (!mounted) return;
        Navigator.pop(context);

        CustomSnackbar.show(
          context: context,
          message: 'Successfully affiliated ${widget.user.fullName} to $selectedMinistry',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Failed to update affiliation. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final ministries = ministryProvider.ministries;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'avatar-${widget.user.id}',
                  child: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      widget.user.fullName[0].toUpperCase(),
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Affiliation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.user.fullName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (!isLoading) IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Current Ministry',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.user.ministry ?? 'No ministry assigned',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Assign to Ministry',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedMinistry,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No ministry'),
                ),
                ...ministries.map((ministry) {
                  return DropdownMenuItem(
                    value: ministry.name,
                    child: Text(ministry.name),
                  );
                }),
              ],
              onChanged: isLoading ? null : (value) {
                setState(() {
                  selectedMinistry = value;
                  hasChanges = value != widget.user.ministry;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: isLoading || !hasChanges
                      ? null
                      : () => _saveAffiliation(context),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AffiliateUsersTab extends StatefulWidget {
  const AffiliateUsersTab({super.key});

  @override
  State<AffiliateUsersTab> createState() => _AffiliateUsersTabState();
}

class _AffiliateUsersTabState extends State<AffiliateUsersTab> {
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final ministryProvider = context.read<MinistryProvider>();

      await Future.wait([
        authProvider.loadUsers(),
        ministryProvider.loadMinistries(),
      ]);
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to load data. Please try again.',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  List<UserCompleteModel> _filterUsers(List<UserCompleteModel> users) {
    if (_searchQuery.isEmpty) return users;

    final searchLower = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.fullName.toLowerCase().contains(searchLower) ||
          (user.ministry?.toLowerCase().contains(searchLower) ?? false) ||
          (user.email.toLowerCase().contains(searchLower));
    }).toList();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AuthProvider>().users;
    final filteredUsers = _filterUsers(users);
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage User Affiliations',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Assign users to their respective ministries',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email or ministry...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              onChanged: (value) {
                _debouncer.run(() {
                  setState(() => _searchQuery = value);
                });
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No users found'
                          : 'No users match your search',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Hero(
                        tag: 'avatar-${user.id}',
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            user.fullName[0].toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.ministry ?? 'No ministry assigned',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AffiliateUserDialog(user: user),
                          );
                        },
                        child: const Text('Edit Affiliation'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this utility class if you don't have it already
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// CustomSnackbar implementation
enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIcon(type),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getColor(type, colorScheme),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  static Color _getColor(SnackbarType type, ColorScheme colorScheme) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return Colors.blue;
    }
  }
}

// Extension methods para formateo de texto
extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get initials {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

// Theme extensions para constantes de diseño
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final double dialogBorderRadius;
  final double cardBorderRadius;
  final EdgeInsets defaultPadding;
  final Duration defaultAnimationDuration;

  AppThemeExtension({
    this.dialogBorderRadius = 16.0,
    this.cardBorderRadius = 12.0,
    this.defaultPadding = const EdgeInsets.all(24.0),
    this.defaultAnimationDuration = const Duration(milliseconds: 300),
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    double? dialogBorderRadius,
    double? cardBorderRadius,
    EdgeInsets? defaultPadding,
    Duration? defaultAnimationDuration,
  }) {
    return AppThemeExtension(
      dialogBorderRadius: dialogBorderRadius ?? this.dialogBorderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      defaultAnimationDuration: defaultAnimationDuration ?? this.defaultAnimationDuration,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
      ThemeExtension<AppThemeExtension>? other,
      double t,
      ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      dialogBorderRadius: lerpDouble(dialogBorderRadius, other.dialogBorderRadius, t) ?? dialogBorderRadius,
      cardBorderRadius: lerpDouble(cardBorderRadius, other.cardBorderRadius, t) ?? cardBorderRadius,
      defaultPadding: EdgeInsets.lerp(defaultPadding, other.defaultPadding, t) ?? defaultPadding,
      defaultAnimationDuration: Duration(
        milliseconds: lerpDouble(
          defaultAnimationDuration.inMilliseconds.toDouble(),
          other.defaultAnimationDuration.inMilliseconds.toDouble(),
          t,
        )?.round() ?? defaultAnimationDuration.inMilliseconds,
      ),
    );
  }
}

// Mixin para manejar el estado de carga
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> runWithLoader(Future<void> Function() callback) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Constantes de la aplicación
class AppConstants {
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration debounceTimeout = Duration(milliseconds: 300);

  static const double defaultBorderRadius = 12.0;
  static const double dialogBorderRadius = 16.0;

  static const EdgeInsets defaultPadding = EdgeInsets.all(24.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);

  static const int minSearchLength = 2;

  // Dimensiones
  static const double maxDialogWidth = 400.0;
  static const double avatarSize = 40.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
}