import 'package:living_word/features/prayers/data/models/prayer_request_model.dart';

class PaginatedPrayersResponse {
  final List<PrayerRequest> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final bool first;
  final bool last;

  PaginatedPrayersResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.first,
    required this.last,
  });

  factory PaginatedPrayersResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedPrayersResponse(
      content: (json['content'] as List)
          .map((item) => PrayerRequest.fromJson(item))
          .toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}
