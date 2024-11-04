  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

  class SecureStorage {
    static const _storage = FlutterSecureStorage();

    static Future<void> saveToken(String token) async {
      await _storage.write(key: 'auth_token', value: token);
    }

    static Future<String?> getToken() async {
      return await _storage.read(key: 'auth_token');
    }

    static Future<void> deleteToken() async {
      await _storage.delete(key: 'auth_token');
    }
    static Future<void> saveDeviceToken(String token) async {
      await _storage.write(key: 'device_token', value: token);
    }

    static Future<String?> getDeviceToken() async {
      return await _storage.read(key: 'device_token');
    }

    static Future<void> deleteDeviceToken() async {
      await _storage.delete(key: 'device_token');
    }

  }
