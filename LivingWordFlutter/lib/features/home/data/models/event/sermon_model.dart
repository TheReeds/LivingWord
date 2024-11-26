class SermonModel {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String videoLink;
  final String summary;
  final bool active;

  SermonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.videoLink,
    required this.summary,
    required this.active,
  });

  factory SermonModel.fromJson(Map<String, dynamic> json) {
    return SermonModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      videoLink: json['videoLink'] as String,
      summary: json['summary'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'videoLink': videoLink,
      'summary': summary,
      'active': active,
    };
  }
}
