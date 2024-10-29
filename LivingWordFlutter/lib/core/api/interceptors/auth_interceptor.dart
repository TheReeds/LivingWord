import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}