import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/event/event_model.dart';

class EventsRepository {
  final Dio _client = ApiClient.instance;

  Future<List<EventModel>> getAllEvents({
    required int page,
    int limit = 10,
    String? ministry,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (ministry != null) 'ministry': ministry,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _client.get(
        ApiConstants.eventsEndpoint,
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al obtener eventos';
        throw Exception(errorMessage);
      }
      throw Exception('Error al obtener eventos: ${e.toString()}');
    }
  }

  Future<List<EventModel>> getMinistryEvents({
    required int page,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _client.get(
        '${ApiConstants.eventsEndpoint}/ministry',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al obtener eventos del ministerio';
        throw Exception(errorMessage);
      }
      throw Exception('Error al obtener eventos del ministerio: ${e.toString()}');
    }
  }

  Future<EventModel> getEventById(int id) async {
    try {
      final response = await _client.get('${ApiConstants.eventsEndpoint}/$id');
      return EventModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al obtener el evento';
        throw Exception(errorMessage);
      }
      throw Exception('Error al obtener el evento: ${e.toString()}');
    }
  }

  Future<EventModel> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    File? imageFile,
  }) async {
    try {
      // Crear el FormData con los campos básicos
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'location': location,
        'eventDate': eventDate.toIso8601String(),
      });

      // Agregar la imagen solo si existe
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'imageFile',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType.parse('image/jpeg'), // O detectar el tipo real del archivo
            ),
          ),
        );
      }

      // Configurar headers específicos para multipart/form-data
      final headers = {
        'Content-Type': 'multipart/form-data',
      };

      final response = await _client.post(
        '${ApiConstants.eventsEndpoint}/create',
        data: formData,
        options: Options(headers: headers),
      );

      return EventModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        print('DioError: ${e.response?.data}'); // Para debugging
        final errorMessage = e.response?.data?['message'] ?? 'Error al crear el evento';
        throw Exception(errorMessage);
      }
      throw Exception('Error al crear el evento: ${e.toString()}');
    }
  }

  Future<EventModel> updateEvent({
    required int id,
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'location': location,
        'eventDate': eventDate.toIso8601String(),
        if (imageFile != null)
          'imageFile': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _client.put(
        '${ApiConstants.eventsEndpoint}/$id',
        data: formData,
      );
      return EventModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al actualizar el evento';
        throw Exception(errorMessage);
      }
      throw Exception('Error al actualizar el evento: ${e.toString()}');
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _client.delete('${ApiConstants.eventsEndpoint}/$id');
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al eliminar el evento';
        throw Exception(errorMessage);
      }
      throw Exception('Error al eliminar el evento: ${e.toString()}');
    }
  }
}