class PrayerRequest {
  final int id;
  final String description;
  final DateTime date;
  final int prayerCount;
  final String username;

  PrayerRequest({
    required this.id,
    required this.description,
    required this.date,
    required this.prayerCount,
    required this.username,
  });

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      prayerCount: json['prayerCount'] ?? 0,
      username: json['username'] ?? '',
    );
  }
}