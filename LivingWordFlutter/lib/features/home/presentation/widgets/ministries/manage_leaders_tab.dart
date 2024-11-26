import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/providers/auth_provider.dart';
import '../../../data/models/ministry_model.dart';
import '../../../providers/ministry_provider.dart';

class ManageLeadersTab extends StatefulWidget {
  @override
  State<ManageLeadersTab> createState() => _ManageLeadersTabState();
}

class _ManageLeadersTabState extends State<ManageLeadersTab> {
  String _ministrySearchQuery = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_isInitialized) {
        context.read<MinistryProvider>().loadMinistries();
        context.read<AuthProvider>().loadUsers();
        _isInitialized = true;
      }
    });
  }

  List<MinistryModel> _filterMinistries(List<MinistryModel> ministries) {
    if (_ministrySearchQuery.isEmpty) return ministries;
    return ministries
        .where((ministry) =>
        ministry.name.toLowerCase().contains(_ministrySearchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final filteredMinistries = _filterMinistries(ministryProvider.ministries);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search ministries...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _ministrySearchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          if (ministryProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (ministryProvider.error != null)
            Center(
              child: Text(
                ministryProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (filteredMinistries.isEmpty)
              const Center(
                child: Text('No ministries found'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMinistries.length,
                  itemBuilder: (context, index) {
                    final ministry = filteredMinistries[index];
                    return _buildMinistryCard(context, ministry);
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMinistryCard(BuildContext context, MinistryModel ministry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          ministry.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Leaders: ${ministry.leaders.length}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          ...ministry.leaders.map(
                (leader) => ListTile(
              leading: CircleAvatar(
                child: Text(
                  '${leader.name[0]}${leader.lastname?[0]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              title: Text('${leader.name} ${leader.lastname}'),
              subtitle: Text(leader.role ?? 'No role assigned'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red,
                onPressed: () => _showRemoveLeaderDialog(context, ministry, leader),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New Leader'),
              onPressed: () => _showAddLeaderDialog(context, ministry),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLeaderDialog(BuildContext context, MinistryModel ministry) {
    String userSearchQuery = '';
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final authProvider = context.watch<AuthProvider>();
          final filteredUsers = authProvider.users.where((user) {
            final searchTerm = userSearchQuery.toLowerCase();
            final fullName = '${user.name} ${user.lastname}'.toLowerCase();
            return searchTerm.isEmpty || fullName.contains(searchTerm);
          }).toList();

          final size = MediaQuery.of(context).size;
          final isSmallScreen = size.width < 600;

          return Dialog(
            // Ajustamos el tamaño máximo del diálogo según el tamaño de la pantalla
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? size.width * 0.9 : 600,
                maxHeight: size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Add Leader to ${ministry.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Contenido principal
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Barra de búsqueda
                          SizedBox(
                            height: 56,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search users...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  userSearchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select a user to assign as leader:',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          // Lista de usuarios
                          Expanded(
                            child: filteredUsers.isEmpty
                                ? const Center(child: Text('No users found'))
                                : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        '${user.name[0]}${user.lastname?[0]}',
                                      ),
                                    ),
                                    title: Text(
                                      '${user.name} ${user.lastname}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Role: ${user.role ?? "No role"}'),
                                        if (user.ministry != null)
                                          Text('Ministry: ${user.ministry}'),
                                      ],
                                    ),
                                    onTap: () => _handleLeaderAssignment(
                                      context,
                                      ministry,
                                      user,
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botones de acción
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLeaderAssignment(
      BuildContext context,
      MinistryModel ministry,
      dynamic user,
      ) async {
    if (user.role != 'LEADER') {
      Navigator.pop(context); // Close dialog first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User must have LEADER role',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Navigator.pop(context); // Close dialog before making the request
      await context.read<MinistryProvider>().assignLeader(
        ministryId: ministry.id,
        userId: user.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An error occurred while assigning the leader',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRemoveLeaderDialog(
      BuildContext context,
      MinistryModel ministry,
      MinistryLeader leader,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Leader'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to remove ${leader.name} ${leader.lastname} as a leader from ${ministry.name}?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog before making the request
              try {
                await context.read<MinistryProvider>().removeLeader(
                  ministryId: ministry.id,
                  userId: leader.id,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'An error occurred while removing the leader',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}