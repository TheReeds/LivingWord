import 'package:dio/dio.dart';
import 'package:living_word/features/auth/data/models/signup_request.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../home/data/models/user_complete_model.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _client = ApiClient.instance;

  Future login(LoginRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        // Revisar si la respuesta tiene un contenido de texto plano
        final errorMessage = e.response?.statusCode == 401
            ? e.response?.data.toString() ?? 'Error al iniciar sesión'
            : e.response?.data?['message'] ?? 'Error al iniciar sesión';
        throw Exception(errorMessage);
      }
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  Future<void> signup(SignupRequest request) async {
    try {
      await _client.post(
        ApiConstants.signupEndpoint,
        data: request.toJson(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al registrarse';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to signup: ${e.toString()}');
    }
  }
  Future<List<UserCompleteModel>> getUsers() async {
    try {
      final response = await _client.get(ApiConstants.usersEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => UserCompleteModel.fromJson(json))
            .toList();
      } else if (response.data['data'] is List) {
        // En caso de que la respuesta venga envuelta en un objeto con una propiedad 'data'
        return (response.data['data'] as List)
            .map((json) => UserCompleteModel.fromJson(json))
            .toList();
      }

      throw Exception('Formato de respuesta inválido');
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error al obtener usuarios';
        throw Exception(errorMessage);
      }
      throw Exception('Error al obtener usuarios: ${e.toString()}');
    }
  }
  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await _client.get('${ApiConstants.usersEndpoint}/$userId');
      return UserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Error fetching user details';
        throw Exception(errorMessage);
      }
      throw Exception('Error fetching user details: ${e.toString()}');
    }
  }
}