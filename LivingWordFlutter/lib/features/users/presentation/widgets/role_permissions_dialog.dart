
import 'package:flutter/material.dart';

import '../../data/models/permission_model.dart';
import '../../data/models/role_model.dart';

class RolePermissionsDialog extends StatefulWidget {
  final Role role;
  final List<Permission> availablePermissions;

  const RolePermissionsDialog({
    Key? key,
    required this.role,
    required this.availablePermissions,
  }) : super(key: key);

  @override
  State<RolePermissionsDialog> createState() => _RolePermissionsDialogState();
}

class _RolePermissionsDialogState extends State<RolePermissionsDialog> {
  late Set<String> _selectedPermissions;

  @override
  void initState() {
    super.initState();
    _selectedPermissions = Set.from(widget.role.permissions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Permisos del Rol: ${widget.role.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: widget.availablePermissions.map((permission) {
            final permissionName = permission.name;
            final isReadPermission = permissionName.endsWith('_READ');
            final displayName = permissionName.replaceAll('_', ' ');

            return CheckboxListTile(
              title: Text(displayName),
              value: _selectedPermissions.contains(permissionName),
              enabled: !isReadPermission, // Los permisos READ siempre están marcados
              onChanged: isReadPermission ? null : (bool? value) {
                setState(() {
                  if (value ?? false) {
                    _selectedPermissions.add(permissionName);
                  } else {
                    _selectedPermissions.remove(permissionName);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selectedPermissions.toList());
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
