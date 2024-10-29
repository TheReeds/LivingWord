import 'package:phone_number/phone_number.dart';

class Validators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  static Future<String?> phoneValidator(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un número de teléfono';
    }
    try {
      final phoneNumberUtil = PhoneNumberUtil();
      final isValid = await phoneNumberUtil.validate(value, regionCode: 'US');
      if (!isValid) {
        return 'Por favor ingrese un número válido';
      }
      return null;
    } catch (e) {
      return 'Número de teléfono inválido';
    }
  }

  static email(String? value) {}
}