import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../data/models/event/event_model.dart';
import '../../../providers/events_provider.dart';
import 'event_form_sheet.dart';

class EventDetailsSheet extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventDetailsSheet({
    Key? key,
    required this.event,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context); // Close details sheet
      try {
        await context.read<EventsProvider>().deleteEvent(event.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting event: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showEditEvent(BuildContext context) {
    Navigator.pop(context); // Close details sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventFormSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    // Permission checks
    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;
    final hasEventEdit = user?.permissions.contains('PERM_EVENT_EDIT') ?? false;
    final hasEventDelete = user?.permissions.contains('PERM_EVENT_DELETE') ?? false;

    // Computed permissions
    final canEdit = hasAdminAccess || hasEventEdit;
    final canDelete = hasAdminAccess || hasEventDelete;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.all(8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Image and actions
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 200,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          ApiConstants.eventImageUrl(event.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        if (canEdit)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditEvent(context),
                          ),
                        if (canDelete)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(context),
                          ),
                      ],
                    ),
                    // Event details
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            // Event info
                            _buildInfoRow(
                              context,
                              Icons.location_on,
                              event.location,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.calendar_today,
                              DateFormat('EEEE, MMMM d, yyyy').format(event.eventDate),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.access_time,
                              DateFormat('HH:mm').format(event.eventDate),
                            ),
                            const SizedBox(height: 24),
                            // Description section
                            Text(
                              'Description',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            // Creator info section
                            Text(
                              'Created by',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.person,
                              '${event.createdByUsername} ${event.createdByLastname}',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.group,
                              event.createdByMinistry,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}