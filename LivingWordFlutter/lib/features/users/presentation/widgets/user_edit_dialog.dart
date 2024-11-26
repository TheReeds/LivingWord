
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

class UserEditDialog extends StatefulWidget {
  final User user;

  const UserEditDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late String _selectedGender;
  late String _selectedMaritalStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
    _selectedGender = widget.user.gender;
    _selectedMaritalStatus = widget.user.maritalstatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _lastnameController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Dirección'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(labelText: 'Género'),
              items: ['Male', 'Female']
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedMaritalStatus,
              decoration: InputDecoration(labelText: 'Estado Civil'),
              items: ['Single', 'Married', 'Divorced', 'Widowed']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMaritalStatus = value);
                }
              },
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
            final updatedUser = User(
              id: widget.user.id,
              name: _nameController.text,
              lastname: _lastnameController.text,
              email: widget.user.email,
              phone: _phoneController.text,
              ministry: widget.user.ministry,
              address: _addressController.text,
              gender: _selectedGender,
              maritalstatus: _selectedMaritalStatus,
              role: widget.user.role,
              photoUrl: widget.user.photoUrl,
            );
            Navigator.pop(context, updatedUser);
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
