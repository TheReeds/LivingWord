class VideoModel {
  final int? id;
  final String title;
  final String youtubeUrl;
  final String? uploadedByUsername;
  final DateTime? uploadedDate;
  final DateTime? publicationDate;  // Añadido para manejar la fecha de publicación

  VideoModel({
    this.id,
    required this.title,
    required this.youtubeUrl,
    this.uploadedByUsername,
    this.uploadedDate,
    this.publicationDate,
  });

  String get youtubeId {
    final uri = Uri.parse(youtubeUrl);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
    return '';
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      youtubeUrl: json['youtubeUrl'],
      uploadedByUsername: json['uploadedByUsername'],
      uploadedDate: json['uploadedDate'] != null
          ? _parseDateTime(json['uploadedDate'])
          : null,
      publicationDate: json['publicationDate'] != null
          ? DateTime.parse(json['publicationDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'youtubeUrl': youtubeUrl,
    };

    // Añadir campos opcionales solo si están presentes
    if (id != null) data['id'] = id;
    if (publicationDate != null) {
      data['publicationDate'] = _formatDate(publicationDate!);
    }
    if (uploadedByUsername != null) {
      data['uploadedByUsername'] = uploadedByUsername;
    }
    if (uploadedDate != null) {
      data['uploadedDate'] = _formatDateTime(uploadedDate!);
    }

    return data;
  }

  // Función auxiliar para parsear el DateTime complejo del servidor
  static DateTime _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.parse(date);
    } else if (date is Map) {
      return DateTime(
        date['year'] ?? 0,
        date['monthValue'] ?? 1,
        date['dayOfMonth'] ?? 1,
        date['hour'] ?? 0,
        date['minute'] ?? 0,
        date['second'] ?? 0,
        0, // milliseconds
        date['nano'] != null ? (date['nano'] ~/ 1000000) : 0, // convertir nanos a micros
      );
    }
    throw FormatException('Invalid date format');
  }

  // Función auxiliar para formatear fecha como yyyy-mm-dd
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Función auxiliar para formatear fecha y hora como yyyy-mm-ddThh:mm:ss
  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)}T${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

}