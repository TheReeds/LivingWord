class MinistrySurveyResponse {
  final int ministryId;
  final String ministryName;
  final String? response;

  MinistrySurveyResponse({
    required this.ministryId,
    required this.ministryName,
    this.response,
  });

  factory MinistrySurveyResponse.fromJson(Map<String, dynamic> json) {
    return MinistrySurveyResponse(
      ministryId: json['ministryId'],
      ministryName: json['ministryName'],
      response: json['response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ministryId': ministryId,
      'response': response,
    };
  }
}