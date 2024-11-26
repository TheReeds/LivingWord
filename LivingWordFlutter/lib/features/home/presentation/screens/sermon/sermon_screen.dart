import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../data/models/event/sermon_model.dart';
import '../../../providers/sermon_provider.dart';
import '../../widgets/sermon/sermon_card.dart';
import '../../widgets/sermon/sermon_form_dialog.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({Key? key}) : super(key: key);

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonProvider>().loadSermons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;
    final hasSermonWrite = user?.permissions.contains('PERM_SERMON_WRITE') ?? false;
    final hasSermonEdit = user?.permissions.contains('PERM_SERMON_EDIT') ?? false;
    final hasSermonDelete = user?.permissions.contains('PERM_SERMON_DELETE') ?? false;

    final canCreateSermon = hasAdminAccess || hasSermonWrite;
    final canEditSermon = hasAdminAccess || hasSermonEdit;
    final canDeleteSermon = hasAdminAccess || hasSermonDelete;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermons'),
      ),
      floatingActionButton: canCreateSermon
          ? FloatingActionButton(
        onPressed: () => _showSermonDialog(context),
        child: const Icon(Icons.add),
      )
          : null,
      body: Consumer<SermonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sermons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: () => provider.loadSermons(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (provider.sermons.isEmpty) {
            return const Center(child: Text('No sermons available'));
          }

          return ListView.builder(
            itemCount: provider.sermons.length,
            itemBuilder: (context, index) {
              final sermon = provider.sermons[index];
              return Card(
                child: SermonCard(
                  sermon: sermon,
                  onEdit: canEditSermon ? () => _showSermonDialog(context, sermon) : null,
                  onDelete: canDeleteSermon ? () => _deleteSermon(context, sermon.id) : null,
                  onStart: canEditSermon ? () => _startSermon(context, sermon.id) : null,
                  onEnd: canEditSermon ? () => _endSermon(context, sermon.id) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSermonDialog(BuildContext context, [SermonModel? sermon]) {
    showDialog(
      context: context,
      builder: (context) => SermonFormDialog(
        sermon: sermon,
        onSubmit: (title, description, startTime, endTime, videoLink, summary) {
          if (sermon == null) {
            // Create new sermon
            context.read<SermonProvider>().createSermon(
              title: title,
              description: description,
              startTime: startTime,
              endTime: endTime,
              videoLink: videoLink,
              summary: summary,
            );
          } else {
            // Update existing sermon
            context.read<SermonProvider>().updateSermon(
              id: sermon.id,
              title: title,
              description: description,
              startTime: startTime,
              endTime: endTime,
              videoLink: videoLink,
              summary: summary,
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteSermon(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sermon'),
        content: const Text('Are you sure you want to delete this sermon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<SermonProvider>().deleteSermon(id);
    }
  }

  Future<void> _startSermon(BuildContext context, int id) async {
    await context.read<SermonProvider>().startSermon(id);
  }

  Future<void> _endSermon(BuildContext context, int id) async {
    await context.read<SermonProvider>().endSermon(id);
  }
}