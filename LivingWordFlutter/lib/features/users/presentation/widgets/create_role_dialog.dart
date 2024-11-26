import 'package:flutter/material.dart';

import '../../data/models/permission_model.dart';

class CreateRoleDialog extends StatefulWidget {
  final List<Permission> availablePermissions;

  const CreateRoleDialog({
    Key? key,
    required this.availablePermissions,
  }) : super(key: key);

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    // Seleccionar automáticamente todos los permisos READ
    _selectedPermissions.addAll(
      widget.availablePermissions
          .where((p) => p.name.endsWith('_READ'))
          .map((p) => p.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear Nuevo Rol'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del Rol'),
            ),
            TextField(
              controller: _levelController,
              decoration: InputDecoration(labelText: 'Nivel'),
              keyboardType: TextInputType.number,
            ),
            ExpansionTile(
              title: Text('Seleccionar Permisos'),
              children: widget.availablePermissions.map((permission) {
                final permissionName = permission.name;
                final isReadPermission = permissionName.endsWith('_READ');
                final displayName = permissionName.replaceAll('_', ' ');
                return CheckboxListTile(
                  title: Text(displayName),
                  value: _selectedPermissions.contains(permissionName),
                  enabled: !isReadPermission,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            final level = int.tryParse(_levelController.text) ?? 1;
            Navigator.pop(context, {'name': name, 'level': level, 'permissions': _selectedPermissions.toList()});
          },
          child: Text('Crear'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }
}