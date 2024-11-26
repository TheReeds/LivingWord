class MinistryResponseDetail {
  final int ministryId;
  final int userId;
  final String userName;
  final String userLastname;
  final String response;

  MinistryResponseDetail({
    required this.ministryId,
    required this.userId,
    required this.userName,
    required this.userLastname,
    required this.response,
  });

  String get fullName => '$userName $userLastname';

  factory MinistryResponseDetail.fromJson(Map<String, dynamic> json) {
    return MinistryResponseDetail(
      ministryId: json['ministryId'],
      userId: json['userId'],
      userName: json['userName'],
      userLastname: json['userLastname'],
      response: json['response'],
    );
  }
}