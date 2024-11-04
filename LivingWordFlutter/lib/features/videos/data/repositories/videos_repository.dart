import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/video_model.dart';

class VideoRepository {
  final Dio _client = ApiClient.instance;

  Future<List<VideoModel>> getVideos({
    required int page,
    required int size,
    required String sortOrder,
  }) async {
    try {
      final response = await _client.get(
        '/videos',
        queryParameters: {
          'page': page,
          'size': size,
          'sortOrder': sortOrder,
        },
      );
      return (response.data as List)
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      throw Exception('Error al obtener videos: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<VideoModel> addVideo(VideoModel video) async {
    try {
      final response = await _client.post(
        '/videos/add',
        data: video.toJson(),
      );
      return VideoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      throw Exception('Error al crear video: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<VideoModel> updateVideo(int id, VideoModel video) async {
    try {
      final response = await _client.put(
        '/videos/$id',
        data: video.toJson(),
      );
      return VideoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      throw Exception('Error al actualizar video: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> deleteVideo(int id) async {
    try {
      await _client.delete('/videos/$id');
    } on DioError catch (e) {
      throw Exception('Error al eliminar video: ${e.response?.data['message'] ?? e.message}');
    }
  }
}