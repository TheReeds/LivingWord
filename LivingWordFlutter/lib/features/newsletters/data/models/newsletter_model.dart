class NewsletterModel {
  final int id;
  final String title;
  final String? newsletterUrl;
  final DateTime publicationDate;
  final int uploadedById;
  final String uploadedByFirstName;
  final String uploadedBySecondName;

  NewsletterModel({
    required this.id,
    required this.title,
    required this.newsletterUrl,
    required this.publicationDate,
    required this.uploadedById,
    required this.uploadedByFirstName,
    required this.uploadedBySecondName,
  });

  factory NewsletterModel.fromJson(Map<String, dynamic> json) {
    return NewsletterModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      newsletterUrl: json['newsletterUrl'],
      publicationDate: DateTime.parse(json['publicationDate']),
      uploadedById: json['uploadedById'] ?? 0,
      uploadedByFirstName: json['uploadedByFirstName'] ?? '',
      uploadedBySecondName: json['uploadedBySecondName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'newsletterUrl': newsletterUrl,
    };
  }
}