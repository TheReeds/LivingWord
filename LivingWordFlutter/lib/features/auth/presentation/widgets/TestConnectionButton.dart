import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class TestConnectionButton extends StatelessWidget {
  const TestConnectionButton({Key? key}) : super(key: key);

  Future<void> _testConnection(BuildContext context) async {
    try {
      final dio = Dio();
      await dio.get(ApiConstants.baseUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión exitosa al servidor'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: ${e.toString()}\n'
                'URL: ${ApiConstants.baseUrl}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _testConnection(context),
      child: const Text('Probar Conexión'),
    );
  }
}