import 'package:flutter/material.dart';
import '../data/repositories/contacts_repository.dart';
import '../data/models/contact_model.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsRepository _repository = ContactsRepository();
  List<ContactModel>? _contacts;
  bool _isLoading = false;
  String? _error;

  List<ContactModel>? get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contacts = await _repository.getContacts();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createContact(Map<String, dynamic> contactData) async {
    try {
      final newContact = await _repository.createContact(contactData);
      _contacts ??= []; // Inicializa la lista si es null
      _contacts!.add(newContact);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateContact(int id, Map<String, dynamic> contactData) async {
    try {
      final updatedContact = await _repository.updateContact(id, contactData);
      final index = _contacts?.indexWhere((contact) => contact.id == id);
      if (index != null && index >= 0) {
        _contacts![index] = updatedContact;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _repository.deleteContact(id);
      await loadContacts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}
