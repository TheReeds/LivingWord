import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/prayer_request_model.dart';
import '../../providers/prayer_provider.dart';

class PrayerCard extends StatelessWidget {
  final PrayerRequest prayer;

  const PrayerCard({Key? key, required this.prayer}) : super(key: key);

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return DateFormat('MMM d, y').format(date);
  }

  bool _canDeletePrayer(List<String> permissions) {
    return permissions.contains('PERM_ADMIN_ACCESS') ||
        permissions.contains('PERM_PRAYER_DELETE');
  }

  void _handleSupportPrayer(BuildContext context) async {
    try {
      await context.read<PrayerProvider>().supportPrayer(prayer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for praying!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        if (e.toString().contains('already prayed')) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Already Prayed'),
              content: const Text('You have already prayed for this request.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error supporting prayer'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _handleDeletePrayer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prayer Request'),
        content: const Text('Are you sure you want to delete this prayer request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await context.read<PrayerProvider>().deletePrayer(prayer.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prayer request deleted successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting prayer request'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSupportersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SupportersDialog(prayerId: prayer.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPermissions = context.read<AuthProvider>().user?.permissions ?? [];

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage:
                        AssetImage('assets/images/default_profile.png'),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayer.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(prayer.date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canDeletePrayer(userPermissions))
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _handleDeletePrayer(context),
                    tooltip: 'Delete prayer request',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prayer.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showSupportersDialog(context),
                  icon: const Icon(Icons.people_outline),
                  label: Text(
                    '${prayer.prayerCount} prayers',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _handleSupportPrayer(context),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('I will pray'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportersDialog extends StatefulWidget {
  final int prayerId;

  const _SupportersDialog({Key? key, required this.prayerId}) : super(key: key);

  @override
  State<_SupportersDialog> createState() => _SupportersDialogState();
}

class _SupportersDialogState extends State<_SupportersDialog> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerProvider>().loadSupporters(widget.prayerId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('People Praying'),
      content: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isSupportersLoading) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final supporters = provider.supporters;

          if (supporters.isEmpty) {
            return const Center(
              child: Text('No one has prayed for this request yet.'),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supporters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage:
                    AssetImage('assets/images/default_profile.png'),
                  ),
                  title: Text(supporters[index]),
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}