class MinistryStatistics {
  final int yesCount;
  final int noCount;
  final int maybeCount;
  final List<String> yesUsers;
  final List<String> noUsers;
  final List<String> maybeUsers;

  MinistryStatistics({
    required this.yesCount,
    required this.noCount,
    required this.maybeCount,
    required this.yesUsers,
    required this.noUsers,
    required this.maybeUsers,
  });

  factory MinistryStatistics.fromJson(Map<String, dynamic> json) {
    return MinistryStatistics(
      yesCount: json['yesCount'] ?? 0,
      noCount: json['noCount'] ?? 0,
      maybeCount: json['maybeCount'] ?? 0,
      yesUsers: List<String>.from(json['yesUsers'] ?? []),
      noUsers: List<String>.from(json['noUsers'] ?? []),
      maybeUsers: List<String>.from(json['maybeUsers'] ?? []),
    );
  }
}