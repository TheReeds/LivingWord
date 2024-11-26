import 'package:dio/dio.dart';
import 'dart:io';

import '../../../../core/api/api_client.dart';
import '../models/user_details_model.dart';

class ProfileRepository {
  final Dio _client = ApiClient.instance;

  ProfileRepository();

  Future<UserDetailsModel> getUserDetails(int userId) async {
    try {
      final response = await _client.get('/users/$userId');
      return UserDetailsModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al obtener detalles del usuario';
        throw Exception(errorMessage);
      }
      throw Exception('Error al obtener detalles del usuario: ${e.toString()}');
    }
  }

  Future<void> updateUserDetails(int userId, UserDetailsModel details) async {
    try {
      await _client.put(
        '/users/$userId',
        data: details.toJson(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al actualizar perfil';
        throw Exception(errorMessage);
      }
      throw Exception('Error al actualizar perfil: ${e.toString()}');
    }
  }

  Future<void> updateProfileImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      await _client.post(
        '/users/updateProfileImage',
        data: formData,
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al actualizar imagen de perfil';
        throw Exception(errorMessage);
      }
      throw Exception('Error al actualizar imagen de perfil: ${e.toString()}');
    }
  }
  Future<void> deleteProfileImage() async {
    try {
      await _client.delete('/users/deleteProfileImage');
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al eliminar imagen de perfil';
        throw Exception(errorMessage);
      }
      throw Exception('Error al eliminar imagen de perfil: ${e.toString()}');
    }
  }
}