import 'package:living_word/features/home/data/models/user_complete_model.dart';

class MinistryModel {
  final int id;
  final String name;
  final String description;
  final List<MinistryLeader> leaders;

  MinistryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.leaders,
  });

  factory MinistryModel.fromJson(Map<String, dynamic> json) {
    return MinistryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      leaders: (json['leaders'] as List<dynamic>?)
          ?.map((leader) => MinistryLeader.fromJson(leader))
          .toList() ?? [],
    );
  }
}
class MinistryLeader {
  final int id;
  final String name;
  final String? lastname;
  final String email;
  final String? phone;
  final String? address;
  final String? gender;
  final String? maritalStatus;
  final String? role;

  MinistryLeader({
    required this.id,
    required this.name,
    this.lastname,
    required this.email,
    this.phone,
    this.address,
    this.gender,
    this.maritalStatus,
    this.role,
  });

  factory MinistryLeader.fromJson(Map<String, dynamic> json) {
    return MinistryLeader(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastname: json['lastname'],
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      gender: json['gender'],
      maritalStatus: json['maritalstatus'],
      role: json['role'],
    );
  }

  String get fullName => '$name ${lastname ?? ''}'.trim();
}