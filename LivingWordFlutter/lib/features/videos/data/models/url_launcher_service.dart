import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<bool> launchURL(String urlString) async {
    final Uri? url = Uri.tryParse(urlString);

    if (url == null) {
      throw Exception('URL inválida: $urlString');
    }

    // Verificar si la URL se puede abrir
    if (await canLaunchUrl(url)) {
      // Intentar abrir la URL con configuraciones específicas
      return await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Forzar apertura en app externa
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } else {
      throw Exception('No se puede abrir la URL: $urlString');
    }
  }

  static Future<bool> launchYouTubeVideo(String videoId) async {
    // Intentar primero la app de YouTube
    final Uri appUri = Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(appUri)) {
      return await launchUrl(appUri);
    }

    // Si no se puede abrir en la app, intentar en el navegador
    final Uri webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    }

    throw Exception('No se puede abrir el video de YouTube');
  }
}