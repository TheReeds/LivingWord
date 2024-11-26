import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as parser;

class YouTubeService {
  static Future<Map<String, dynamic>> getVideoData(String videoUrl) async {
    try {
      // Extraer ID del video
      final uri = Uri.parse(videoUrl);
      String videoId = '';
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.first;
      } else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'] ?? '';
      }

      if (videoId.isEmpty) {
        throw Exception('Invalid YouTube URL');
      }

      // Hacer request a la página del video para obtener metadatos
      final response = await http.get(Uri.parse('https://www.youtube.com/watch?v=$videoId'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load video data');
      }

      final document = parser.parse(response.body);

      // Extraer metadatos usando las etiquetas meta
      final title = document.querySelector('meta[property="og:title"]')?.attributes['content'] ?? '';
      final channelName = document.querySelector('meta[property="og:video:tag"]')?.attributes['content'] ?? '';
      final description = document.querySelector('meta[property="og:description"]')?.attributes['content'] ?? '';

      // Obtener duración aproximada del video usando la API de YouTube oEmbed
      final oembedResponse = await http.get(
          Uri.parse('https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json')
      );

      final oembedData = json.decode(oembedResponse.body);

      return {
        'videoId': videoId,
        'title': title,
        'channelName': channelName,
        'description': description,
        'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
        'channelThumbnail': oembedData['thumbnail_url'] ?? '',
      };
    } catch (e) {
      print('Error getting video data: $e');
      return {};
    }
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }
}