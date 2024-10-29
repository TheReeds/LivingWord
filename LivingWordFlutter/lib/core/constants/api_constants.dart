import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    // Si estás usando un dispositivo físico, reemplaza esta IP con la de tu computadora
    const String deviceIp = '192.168.1.100'; // Cambia esta IP por la de tu máquina

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (!kReleaseMode) {
        // Emulador Android
        return 'http://10.0.2.2:6500';
      }
      // Dispositivo Android físico
      return 'http://$deviceIp:6500';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (!kReleaseMode) {
        // Simulador iOS
        return 'http://localhost:6500';
      }
      // Dispositivo iOS físico
      return 'http://$deviceIp:6500';
    }
    // Default fallback
    return 'http://localhost:6500';
  }
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
}