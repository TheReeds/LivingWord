import 'package:flutter/material.dart';
import 'package:living_word/features/home/presentation/screens/sermon/sermon_screen.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/event/event_model.dart';
import '../../providers/events_provider.dart';
import '../widgets/events/event_details_sheet.dart';
import '../widgets/events/event_filter_dialog.dart';
import '../widgets/events/event_form_sheet.dart';
import 'events/event_card.dart';


class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents(page: _currentPage);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreEvents();
    }
  }

  Future<void> _loadMoreEvents() async {
    if (!context.read<EventsProvider>().isLoading) {
      _currentPage++;
      await context.read<EventsProvider>().loadEvents(
        page: _currentPage,
        ministryOnly: context.read<EventsProvider>().isMinistryView,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;

    // Permission checks
    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;
    final hasEventWrite = user?.permissions.contains('PERM_EVENT_WRITE') ?? false;
    final hasEventEdit = user?.permissions.contains('PERM_EVENT_EDIT') ?? false;
    final hasEventDelete = user?.permissions.contains('PERM_EVENT_DELETE') ?? false;

    // Computed permissions
    final canCreateEvent = hasAdminAccess || hasEventWrite;
    final canEditEvent = hasAdminAccess || hasEventEdit;
    final canDeleteEvent = hasAdminAccess || hasEventDelete;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Church Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Announcements'),
            Tab(text: 'Sermons'),
          ],
        ),
      ),
      floatingActionButton: canCreateEvent ? _buildFAB() : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementsTab(canEditEvent: canEditEvent, canDeleteEvent: canDeleteEvent),
          const SermonsScreen(), // Replace the "Coming Soon" with SermonsScreen
        ],
      ),
    );
  }

  Widget? _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showEventDialog(context),
      child: const Icon(Icons.add),
    );
  }
  Widget _buildAnnouncementsTab({
    required bool canEditEvent,
    required bool canDeleteEvent,
  }) {
    return Consumer<EventsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildFilterBar(provider),
            Expanded(
              child: provider.isLoading && provider.events.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? _buildErrorView(provider.error!)
                  : provider.events.isEmpty
                  ? _buildEmptyView()
                  : _buildEventGrid(
                provider,
                canEditEvent: canEditEvent,
                canDeleteEvent: canDeleteEvent,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(EventsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: false,
                label: Text('All Events'),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text('My Ministry'),
              ),
            ],
            selected: {provider.isMinistryView},
            onSelectionChanged: (Set<bool> newSelection) {
              _currentPage = 1;
              provider.loadEvents(
                page: _currentPage,
                ministryOnly: newSelection.first,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEventGrid(
      EventsProvider provider, {
        required bool canEditEvent,
        required bool canDeleteEvent,
      }) {
    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        await provider.loadEvents(
          page: _currentPage,
          ministryOnly: provider.isMinistryView,
        );
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.events.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.events.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return EventCard(
            event: provider.events[index],
            onTap: () => _showEventDetails(
              context,
              provider.events[index],
              canEdit: canEditEvent,
              canDelete: canDeleteEvent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          const Text('No events available'),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _currentPage = 1;
              context.read<EventsProvider>().loadEvents(page: _currentPage);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, [EventModel? event]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventFormSheet(event: event),
    );
  }

  void _showEventDetails(
      BuildContext context,
      EventModel event, {
        required bool canEdit,
        required bool canDelete,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsSheet(
        event: event,
        onEdit: canEdit ? () => _showEditEventDialog(context, event) : null,
        onDelete: canDelete ? () => _showDeleteConfirmation(context, event) : null,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EventFilterDialog(),
    );
  }
  void _showDeleteConfirmation(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);

              try {
                await context.read<EventsProvider>().deleteEvent(event.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting event: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventFormSheet(event: event),
    );
  }

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

}