import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/sermon_note_model.dart';

class SermonNotesRepository {
  final Dio _client = ApiClient.instance;

  Future<Map<String, dynamic>> getSermonNotes({
    int page = 0,
    int size = 10,
    String sort = 'desc',
  }) async {
    try {
      final response = await _client.get(
        '/sermonnotes',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      return {
        'content': (response.data['content'] as List)
            .map((json) => SermonNoteModel.fromJson(json))
            .toList(),
        'totalPages': response.data['totalPages'],
        'totalElements': response.data['totalElements'],
        'last': response.data['last'],
      };
    } catch (e) {
      throw Exception('Error al obtener sermon notes: ${e.toString()}');
    }
  }

  Future<SermonNoteModel> getSermonNoteById(int id) async {
    try {
      final response = await _client.get('/sermonnotes/$id');
      return SermonNoteModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener sermon note: ${e.toString()}');
    }
  }

  Future<SermonNoteModel> createSermonNote(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/sermonnotes', data: data);
      return SermonNoteModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear sermon note: ${e.toString()}');
    }
  }

  Future<SermonNoteModel> updateSermonNote(int id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/sermonnotes/$id', data: data);
      return SermonNoteModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar sermon note: ${e.toString()}');
    }
  }

  Future<void> deleteSermonNote(int id) async {
    try {
      await _client.delete('/sermonnotes/$id');
    } catch (e) {
      throw Exception('Error al eliminar sermon note: ${e.toString()}');
    }
  }
}