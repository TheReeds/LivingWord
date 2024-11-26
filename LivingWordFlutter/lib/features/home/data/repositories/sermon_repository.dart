import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/event/sermon_model.dart';

class SermonRepository {
  final Dio _client = ApiClient.instance;

  Future<List<SermonModel>> getSermons() async {
    try {
      final response = await _client.get('/sermons');
      return (response.data as List)
          .map((item) => SermonModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching sermons: ${e.toString()}');
    }
  }

  Future<SermonModel> getSermonById(int id) async {
    try {
      final response = await _client.get('/sermons/$id');
      return SermonModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching sermon: ${e.toString()}');
    }
  }

  Future<SermonModel> createSermon({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String videoLink,
    required String summary,
  }) async {
    try {
      final response = await _client.post(
        '/sermons',
        data: {
          'title': title,
          'description': description,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'videoLink': videoLink,
          'summary': summary,
        },
      );
      return SermonModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error creating sermon: ${e.toString()}');
    }
  }

  Future<SermonModel> updateSermon({
    required int id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String videoLink,
    required String summary,
  }) async {
    try {
      final response = await _client.put(
        '/sermons/$id',
        data: {
          'title': title,
          'description': description,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'videoLink': videoLink,
          'summary': summary,
        },
      );
      return SermonModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error updating sermon: ${e.toString()}');
    }
  }

  Future<SermonModel> startSermon(int id) async {
    try {
      final response = await _client.post('/sermons/$id/start');
      return SermonModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error starting sermon: ${e.toString()}');
    }
  }

  Future<SermonModel> endSermon(int id) async {
    try {
      final response = await _client.post('/sermons/$id/end');
      return SermonModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error ending sermon: ${e.toString()}');
    }
  }

  Future<void> deleteSermon(int id) async {
    try {
      await _client.delete('/sermons/$id');
    } catch (e) {
      throw Exception('Error deleting sermon: ${e.toString()}');
    }
  }
}