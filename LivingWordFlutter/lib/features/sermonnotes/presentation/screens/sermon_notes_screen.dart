import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../data/models/sermon_note_model.dart';
import '../../providers/sermon_notes_provider.dart';
import '../widgets/sermon_note_card.dart';
import '../widgets/add_edit_sermon_note_dialog.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class SermonNotesScreen extends StatefulWidget {
  const SermonNotesScreen({Key? key}) : super(key: key);

  @override
  State<SermonNotesScreen> createState() => _SermonNotesScreenState();
}

class _SermonNotesScreenState extends State<SermonNotesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonNotesProvider>().loadSermonNotes(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<SermonNotesProvider>();
      if (!provider.isLoading && !provider.isLastPage) {
        provider.loadSermonNotes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SermonNotesProvider>(
      builder: (context, authProvider, sermonNotesProvider, child) {
        final user = authProvider.user;
        final hasWritePermission = user?.permissions.contains('PERM_SERMONNOTE_WRITE') ?? false;
        final hasEditPermission = user?.permissions.contains('PERM_SERMONNOTE_EDIT') ?? false;
        final hasDeletePermission = user?.permissions.contains('PERM_SERMONNOTE_DELETE') ?? false;
        final isAdmin = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;

        return Scaffold(
          appBar: _buildAppBar(sermonNotesProvider),
          body: RefreshIndicator(
            onRefresh: () => sermonNotesProvider.loadSermonNotes(refresh: true),
            child: Builder(
              builder: (context) {
                if (sermonNotesProvider.error != null) {
                  return _buildErrorState(sermonNotesProvider.error!);
                }

                if (sermonNotesProvider.sermonNotes == null && sermonNotesProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (sermonNotesProvider.sermonNotes?.isEmpty ?? true) {
                  return _buildEmptyState(hasWritePermission || isAdmin);
                }

                return _buildSermonNotesList(
                  sermonNotesProvider,
                  hasEditPermission || isAdmin,
                  hasDeletePermission || isAdmin,
                );
              },
            ),
          ),
          floatingActionButton: hasWritePermission || isAdmin
              ? FloatingActionButton.extended(
            onPressed: () => _showAddEditDialog(context),
            label: const Text('New Note'),
            icon: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SermonNotesProvider sermonNotesProvider) {
    return AppBar(
      title: const Text(
        'Sermon Notes',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => sermonNotesProvider.toggleSortOrder(),
          icon: Icon(
            sermonNotesProvider.sortOrder == 'desc' ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.black,
          ),
          label: Text(
            sermonNotesProvider.sortOrder == 'desc' ? 'Most Recent' : 'Oldest First',
            style: const TextStyle(color: Colors.black),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading sermon notes',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SermonNotesProvider>().loadSermonNotes(refresh: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool canAdd) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No sermon notes available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (canAdd) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Sermon Note'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSermonNotesList(
      SermonNotesProvider provider,
      bool canEdit,
      bool canDelete,
      ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: (provider.sermonNotes?.length ?? 0) + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.sermonNotes?.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final note = provider.sermonNotes![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SermonNoteCard(
            sermonNote: note,
            onEdit: canEdit
                ? (authProvider) => _showAddEditDialog(context, sermonNote: note)
                : null,
            onDelete: canDelete
                ? (authProvider) => _showDeleteDialog(context, note)
                : null,
          ),
        );
      },
    );
  }

  Future<void> _showAddEditDialog(BuildContext context, {SermonNoteModel? sermonNote}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditSermonNoteDialog(sermonNote: sermonNote),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sermonNote == null
                ? 'Sermon note created successfully'
                : 'Sermon note updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, SermonNoteModel sermonNote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sermon Note'),
        content: Text('Are you sure you want to delete "${sermonNote.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<SermonNotesProvider>().deleteSermonNote(sermonNote.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sermon note deleted successfully'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting sermon note: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
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
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}