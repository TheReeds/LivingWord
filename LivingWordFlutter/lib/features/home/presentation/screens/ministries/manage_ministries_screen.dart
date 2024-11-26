import 'package:flutter/material.dart';
import 'package:living_word/features/home/providers/ministry_provider.dart';
import 'package:provider/provider.dart';

import '../../../../auth/providers/auth_provider.dart';
import '../../../data/models/ministry_model.dart';
import '../../widgets/ministries/create_ministry_dialog.dart';
import '../../widgets/ministries/edit_ministry_dialog.dart';
import '../../widgets/ministries/manage_leaders_tab.dart';
import 'affiliate_management_screen.dart';
import 'ministry_details_screen.dart';

class ManageMinstriesScreen extends StatelessWidget {
  const ManageMinstriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Ministries'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ministries'),
              Tab(text: 'Affiliate'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MinistryManagementTab(),
            AffiliateManagementTab(),
          ],
        ),
      ),
    );
  }
}

class MinistryManagementTab extends StatefulWidget {
  const MinistryManagementTab({Key? key}) : super(key: key);

  @override
  State<MinistryManagementTab> createState() => _MinistryManagementTabState();
}

class _MinistryManagementTabState extends State<MinistryManagementTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMinistries();
  }

  Future<void> _loadMinistries() async {
    try {
      await context.read<MinistryProvider>();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load ministries');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ministriesProvider = context.watch<MinistryProvider>();
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.permissions.contains('PERM_MINISTRY_EDIT') ?? false;
    final canDelete = user?.permissions.contains('PERM_MINISTRY_DELETE') ?? false;
    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;

    return RefreshIndicator(
      onRefresh: _loadMinistries,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showCreateMinistryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Ministry'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ministriesProvider.ministries.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.church, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No ministries found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: _loadMinistries,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: ministriesProvider.ministries.length,
                itemBuilder: (context, index) {
                  final ministry = ministriesProvider.ministries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        ministry.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            ministry.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (canEdit || hasAdminAccess)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Ministry',
                              onPressed: () => _showEditMinistryDialog(
                                context,
                                ministry,
                              ),
                            ),
                          if (canDelete || hasAdminAccess)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              tooltip: 'Delete Ministry',
                              onPressed: () => _showDeleteConfirmDialog(
                                context,
                                ministry,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _showMinistryDetails(context, ministry),
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

  Future<void> _showCreateMinistryDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateMinistryDialog(),
    );

    if (result == true && mounted) {
      _showSuccessSnackBar('Ministry created successfully');
      _loadMinistries();
    }
  }

  Future<void> _showEditMinistryDialog(BuildContext context, MinistryModel ministry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditMinistryDialog(ministry: ministry),
    );

    if (result == true && mounted) {
      _showSuccessSnackBar('Ministry updated successfully');
      _loadMinistries();
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, MinistryModel ministry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ministry'),
        content: Text('Are you sure you want to delete ${ministry.name}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await context.read<MinistryProvider>().deleteMinistry(ministry.id);
        _showSuccessSnackBar('Ministry deleted successfully');
        _loadMinistries();
      } catch (e) {
        _showErrorSnackBar('Failed to delete ministry');
      }
    }
  }

  void _showMinistryDetails(BuildContext context, MinistryModel ministry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MinistryDetailsScreen(ministry: ministry),
      ),
    );
  }
}

class AffiliateManagementTab extends StatelessWidget {
  const AffiliateManagementTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Affiliate Members'),
              Tab(text: 'Manage Leaders'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AffiliateUsersTab(),
                ManageLeadersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}