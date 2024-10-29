import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ))..interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true), // Para debugging
    ]);

    return _dio!;
  }
}