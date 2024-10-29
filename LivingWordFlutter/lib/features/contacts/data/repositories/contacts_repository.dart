import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/contact_model.dart';

class ContactsRepository {
  final Dio _client = ApiClient.instance;

  Future<List<ContactModel>> getContacts() async {
    try {
      final response = await _client.get('/contacts');
      return (response.data as List)
          .map((json) => ContactModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener contactos: ${e.toString()}');
    }
  }

  Future<ContactModel> createContact(Map<String, dynamic> contactData) async {
    try {
      final response = await _client.post('/contacts', data: contactData);
      return ContactModel.fromJson(response.data); // Asegúrate de que esto esté devolviendo el modelo correcto
    } catch (e) {
      throw Exception('Error al crear contacto: ${e.toString()}');
    }
  }

  Future<ContactModel> updateContact(int id, Map<String, dynamic> contactData) async {
    try {
      final response = await _client.put('/contacts/$id', data: contactData);
      return ContactModel.fromJson(response.data); // Asegúrate de que esto esté devolviendo el modelo correcto
    } catch (e) {
      throw Exception('Error al actualizar contacto: ${e.toString()}');
    }
  }


  Future<void> deleteContact(int id) async {
    try {
      await _client.delete('/contacts/$id');
    } catch (e) {
      throw Exception('Error al eliminar contacto: ${e.toString()}');
    }
  }
}