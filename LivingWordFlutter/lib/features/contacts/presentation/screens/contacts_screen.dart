import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/contact_card.dart';
import 'contact_form_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContactsProvider()..loadContacts(),
      child: const ContactsScreenContent(),
    );
  }
}

class ContactsScreenContent extends StatelessWidget {
  const ContactsScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contactsProvider = context.watch<ContactsProvider>();
    final user = context.watch<AuthProvider>().user;
    final hasEditPermission = user?.permissions.contains('PERM_CONTACT_EDIT') ?? false;
    final hasDeletePermission = user?.permissions.contains('PERM_CONTACT_DELETE') ?? false;
    final hasWritePermission = user?.permissions.contains('PERM_CONTACT_WRITE') ?? false;
    final isAdmin = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;

    if (contactsProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (contactsProvider.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${contactsProvider.error}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        elevation: 0,
      ),
      body: contactsProvider.contacts?.isEmpty ?? true
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_phone_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay contactos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contactsProvider.contacts?.length ?? 0,
        itemBuilder: (context, index) {
          final contact = contactsProvider.contacts![index];
          return ContactCard(
            contact: contact,
            canEdit: hasEditPermission || isAdmin,
            canDelete: hasDeletePermission || isAdmin,
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactFormScreen(contact: contact),
                ),
              );
              if (result == true) {
                await contactsProvider.loadContacts();
              }
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: Text('¿Estás seguro de eliminar a ${contact.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await contactsProvider.deleteContact(contact.id);
              }
            },
          );
        },
      ),
      floatingActionButton: (hasWritePermission || isAdmin)
          ? Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactFormScreen(),
              ),
            );
            if (result == true) {
              await contactsProvider.loadContacts();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('New Contact'),
          elevation: 4,
        ),
      )
          : null,
    );
  }
}