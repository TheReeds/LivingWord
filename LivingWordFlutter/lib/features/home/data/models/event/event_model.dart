
class EventModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime eventDate;
  final int addedById;
  final String createdByUsername;
  final String createdByLastname;
  final String createdByMinistry;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.eventDate,
    required this.addedById,
    required this.createdByUsername,
    required this.createdByLastname,
    required this.createdByMinistry,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      addedById: json['addedById'] as int,
      createdByUsername: json['createdByUsername'] as String,
      createdByLastname: json['createdByLastname'] as String,
      createdByMinistry: json['createdByMinistry'] as String,
    );
  }
}