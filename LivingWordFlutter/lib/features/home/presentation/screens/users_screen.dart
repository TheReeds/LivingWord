import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../users/data/models/role_model.dart';
import '../../../users/data/models/user_model.dart';
import '../../../users/presentation/widgets/role_permissions_dialog.dart';
import '../../../users/presentation/widgets/user_edit_dialog.dart';
import '../../../users/providers/user_management_provider.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;
    final hasUserWrite = user?.permissions.contains('PERM_USER_WRITE') ?? false;
    final hasUserDelete = user?.permissions.contains('PERM_USER_DELETE') ?? false;
    final hasUserRead = user?.permissions.contains('PERM_USER_READ') ?? false;
    final showUserManageOptions = hasAdminAccess || hasUserWrite;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Usuarios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Usuarios'),
              Tab(text: 'Roles'),
              Tab(text: 'Permisos'),
              Tab(text: 'Asignar Roles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserListTab(
              showUserManageOptions: showUserManageOptions,
              hasUserWrite: hasUserWrite,
              hasUserDelete: hasUserDelete,
            ),
            RolesTab(),
            PermissionsTab(),
            AssignRolesTab(),
          ],
        ),
      ),
    );
  }
}

class UserListTab extends StatefulWidget {
  final bool showUserManageOptions;
  final bool hasUserWrite;
  final bool hasUserDelete;

  const UserListTab({
    super.key,
    required this.showUserManageOptions,
    required this.hasUserWrite,
    required this.hasUserDelete,
  });

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab> {
  @override
  void initState() {
    super.initState();
    context.read<UserManagementProvider>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final users = provider.users;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: user.photoUrl != null
                  ? Image.network(
                ApiConstants.profileImageUrl(user.photoUrl!),
                fit: BoxFit.cover,
                width: 36,
                height: 36,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default_profile.png',
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.blue[200],
                    ),
                  );
                },
              )
                  : Image.asset(
                'assets/images/default_profile.png',
                fit: BoxFit.cover,
                width: 36,
                height: 36,
              ),
            ),
          ),
          title: Text('${user.name} ${user.lastname}'),
          subtitle: Text(user.email),
          trailing: widget.showUserManageOptions
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.hasUserWrite)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditUserDialog(context, user);
                  },
                ),
              if (widget.hasUserDelete)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    provider.deleteUser(user.id);
                  },
                ),
            ],
          )
              : null,
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, User user) async {
    final updatedUser = await showDialog<User>(
      context: context,
      builder: (context) => UserEditDialog(user: user),
    );
    if (updatedUser != null) {
      context.read<UserManagementProvider>().updateUser(user.id, updatedUser);
    }
  }
}

class RolesTab extends StatefulWidget {
  @override
  State<RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<RolesTab> {
  @override
  void initState() {
    super.initState();
    context.read<UserManagementProvider>().fetchRoles();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final roles = provider.roles;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return ListTile(
          title: Text(role.name),
          subtitle: Text('Nivel: ${role.level}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showPermissionsDialog(context, role);
            },
          ),
        );
      },
    );
  }

  void _showPermissionsDialog(BuildContext context, Role role) async {
    final provider = context.read<UserManagementProvider>();

    // Asegúrate de que los permisos se carguen antes de abrir el diálogo
    await provider.fetchPermissions();

    final availablePermissions = provider.permissions;

    final updatedPermissions = await showDialog<List<String>>(
      context: context,
      builder: (context) => RolePermissionsDialog(
        role: role,
        availablePermissions: availablePermissions,
      ),
    );
    if (updatedPermissions != null) {
      provider.updateRolePermissions(role.id, updatedPermissions);
    }
  }
}

class PermissionsTab extends StatefulWidget {
  @override
  State<PermissionsTab> createState() => _PermissionsTabState();
}

class _PermissionsTabState extends State<PermissionsTab> {
  @override
  void initState() {
    super.initState();
    context.read<UserManagementProvider>().fetchPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final permissions = provider.permissions;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: permissions.length,
      itemBuilder: (context, index) {
        final permission = permissions[index];
        final displayName = permission.name.replaceAll('_', ' ');
        return ListTile(
          title: Text(displayName),
        );
      },
    );
  }
}

class AssignRolesTab extends StatefulWidget {
  @override
  State<AssignRolesTab> createState() => _AssignRolesTabState();
}

class _AssignRolesTabState extends State<AssignRolesTab> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<UserManagementProvider>();
    provider.fetchUsers();
    provider.fetchRoles();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final users = provider.users;
    final roles = provider.roles;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text('${user.name} ${user.lastname}'),
          subtitle: Text('Rol actual: ${user.role}'),
          trailing: DropdownButton<String>(
            value: user.role,
            items: roles.map((role) {
              return DropdownMenuItem(
                value: role.name,
                child: Text(role.name),
              );
            }).toList(),
            onChanged: (String? newRole) {
              if (newRole != null) {
                final roleId = roles.firstWhere((role) => role.name == newRole).id;
                provider.assignRole(user.id, roleId);
              }
            },
          ),
        );
      },
    );
  }
}
