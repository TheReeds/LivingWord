import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ministry_model.dart';
import '../../../data/models/user_complete_model.dart';
import '../../../providers/ministry_provider.dart';

class MinistryDetailsScreen extends StatefulWidget {
  final MinistryModel ministry;

  const MinistryDetailsScreen({
    Key? key,
    required this.ministry,
  }) : super(key: key);

  @override
  State<MinistryDetailsScreen> createState() => _MinistryDetailsScreenState();
}

class _MinistryDetailsScreenState extends State<MinistryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load ministry data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MinistryProvider>()
        ..loadMinistryById(widget.ministry.id)
        ..loadMinistryMembers(widget.ministry.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final members = ministryProvider.ministryMembers;
    final isLoading = ministryProvider.isLoading;
    final error = ministryProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ministry.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit ministry screen
            },
          ),
        ],
      ),
      body: error != null
          ? _buildErrorState(error)
          : RefreshIndicator(
        onRefresh: () async {
          await ministryProvider.loadMinistryById(widget.ministry.id);
          await ministryProvider.loadMinistryMembers(widget.ministry.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMinistryInfo(context),
              const SizedBox(height: 24),
              _buildLeadersSection(context),
              const SizedBox(height: 24),
              _buildMembersSection(context, isLoading, members),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add member screen
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading ministry details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<MinistryProvider>()
                  ..loadMinistryById(widget.ministry.id)
                  ..loadMinistryMembers(widget.ministry.id);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinistryInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  'Ministry Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              widget.ministry.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadersSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_outline),
                    const SizedBox(width: 8),
                    Text(
                      'Leaders',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    // TODO: Show dialog to add leader
                  },
                ),
              ],
            ),
            const Divider(),
            if (widget.ministry.leaders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('No leaders assigned yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.ministry.leaders.length,
                itemBuilder: (context, index) {
                  final leader = widget.ministry.leaders[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        leader.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(leader.fullName),
                    subtitle: Text(leader.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      onPressed: () {
                        _showRemoveLeaderDialog(context, leader);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(
      BuildContext context,
      bool isLoading,
      List<UserCompleteModel> members,
      ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_outline),
                const SizedBox(width: 8),
                Text(
                  'Members',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('No members in this ministry'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        member.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(member.fullName),
                    subtitle: Text(member.email),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'promote',
                          child: Text('Promote to Leader'),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove from Ministry'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'promote') {
                          _promoteToLeader(member);
                        } else if (value == 'remove') {
                          _showRemoveMemberDialog(context, member);
                        }
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveLeaderDialog(
      BuildContext context,
      MinistryLeader leader,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Leader'),
        content: Text(
          'Are you sure you want to remove ${leader.fullName} as a leader?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<MinistryProvider>();
      await provider.removeLeader(
        ministryId: widget.ministry.id,
        userId: leader.id,
      );
    }
  }

  Future<void> _showRemoveMemberDialog(
      BuildContext context,
      UserCompleteModel member,
      ) async {
    // TODO: Implement remove member dialog
  }

  Future<void> _promoteToLeader(UserCompleteModel member) async {
    final provider = context.read<MinistryProvider>();
    await provider.assignLeader(
      ministryId: widget.ministry.id,
      userId: member.id,
    );
  }
}