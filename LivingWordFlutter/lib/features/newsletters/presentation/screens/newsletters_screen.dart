import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/newsletter_model.dart';
import '../../providers/newsletters_provider.dart';
import '../widgets/newsletter_card.dart';
import '../widgets/newsletter_form.dart';
class _NewsletterPermissions {
  final bool canEdit;
  final bool canDelete;
  final bool canWrite;
  final bool isAdmin;

  _NewsletterPermissions({
    required this.canEdit,
    required this.canDelete,
    required this.canWrite,
    required this.isAdmin,
  });

  bool get canCreateNewsletter => canWrite || isAdmin;
  bool get canEditNewsletter => canEdit || isAdmin;
  bool get canDeleteNewsletter => canDelete || isAdmin;
}

class NewsletterScreen extends StatefulWidget {
  const NewsletterScreen({Key? key}) : super(key: key);

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  @override
  void initState() {
    super.initState();
    // Programar la carga para después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewslettersProvider>().loadNewsletters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const NewsletterScreenContent();
  }
}

class NewsletterScreenContent extends StatelessWidget {
  const NewsletterScreenContent({Key? key}) : super(key: key);


  Future<void> _handleNewsletterCreation(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: NewsletterForm(
            onSubmit: (title, url) {
              Navigator.of(context).pop({'title': title, 'url': url});
            },
          ),
        ),
      ),
    );

    if (result != null && context.mounted) {
      try {
        final provider = context.read<NewslettersProvider>();
        await provider.createNewsletter(
          title: result['title']!,
          newsletterUrl: result['url']!,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Newsletter created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating newsletter: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleNewsletterEdit(
      BuildContext context,
      NewsletterModel newsletter,
      ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: NewsletterForm(
            newsletter: newsletter,
            onSubmit: (title, url) {
              Navigator.of(context).pop({'title': title, 'url': url});
            },
          ),
        ),
      ),
    );

    if (result != null && context.mounted) {
      try {
        final provider = context.read<NewslettersProvider>();
        await provider.updateNewsletter(
          id: newsletter.id,
          title: result['title']!,
          newsletterUrl: result['url']!,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Newsletter updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating newsletter: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewslettersProvider, AuthProvider>(
      builder: (context, newslettersProvider, authProvider, _) {
        final user = authProvider.user;
        final state = newslettersProvider.state;
        final permissions = _NewsletterPermissions(
          canEdit: user?.permissions.contains('PERM_NEWSLETTER_EDIT') ?? false,
          canDelete: user?.permissions.contains('PERM_NEWSLETTER_DELETE') ?? false,
          canWrite: user?.permissions.contains('PERM_NEWSLETTER_WRITE') ?? false,
          isAdmin: user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false,
        );

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => newslettersProvider.loadNewsletters(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Newsletters'),
            elevation: 0,
          ),
          body: _NewsletterList(
            state: state,
            permissions: permissions,
            onEdit: (newsletter) => _handleNewsletterEdit(context, newsletter),
            onDelete: (newsletter) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm deletion'),
                  content: Text('Are you sure you want to delete "${newsletter.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  await newslettersProvider.deleteNewsletter(newsletter.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Newsletter deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting newsletter: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            onLoadMore: () => newslettersProvider.loadNewsletters(
              page: state.currentPage + 1,
            ),
          ),
          floatingActionButton: permissions.canCreateNewsletter
              ? FloatingActionButton.extended(
            onPressed: () => _handleNewsletterCreation(context),
            icon: const Icon(Icons.add),
            label: const Text('New Newsletter'),
          )
              : null,
        );
      },
    );
  }
}

class _NewsletterList extends StatelessWidget {
  final NewslettersState state;
  final _NewsletterPermissions permissions;
  final Function(NewsletterModel) onEdit;
  final Function(NewsletterModel) onDelete;
  final VoidCallback onLoadMore;

  const _NewsletterList({
    required this.state,
    required this.permissions,
    required this.onEdit,
    required this.onDelete,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.newsletters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.newsletters.isEmpty && state.featuredNewsletter == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No newsletters available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NewslettersProvider>().loadNewsletters(),
      child: ListView(
        children: [
          if (state.featuredNewsletter != null)
            NewsletterCard(
              newsletter: state.featuredNewsletter!,
              canEdit: permissions.canEditNewsletter,
              canDelete: permissions.canDeleteNewsletter,
              onEdit: () => onEdit(state.featuredNewsletter!),
              onDelete: () => onDelete(state.featuredNewsletter!),
              isFeatured: true,
            ),
          ...state.newsletters.map(
                (newsletter) => NewsletterCard(
              newsletter: newsletter,
              canEdit: permissions.canEditNewsletter,
              canDelete: permissions.canDeleteNewsletter,
              onEdit: () => onEdit(newsletter),
              onDelete: () => onDelete(newsletter),
            ),
          ),
          if (state.currentPage < state.totalPages - 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
