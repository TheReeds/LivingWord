class SermonNoteModel {
  final int id;
  final String title;
  final String sermonUrl;
  final DateTime date;
  final int addedById;
  final String addedByName;
  final String addedByLastname;

  SermonNoteModel({
    required this.id,
    required this.title,
    required this.sermonUrl,
    required this.date,
    required this.addedById,
    required this.addedByName,
    required this.addedByLastname,
  });

  factory SermonNoteModel.fromJson(Map<String, dynamic> json) {
    return SermonNoteModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      sermonUrl: json['sermonurl'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      addedById: json['addedById'] ?? 0,
      addedByName: json['addedByName'] ?? '',
      addedByLastname: json['addedByLastname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sermonurl': sermonUrl,
    };
  }
}