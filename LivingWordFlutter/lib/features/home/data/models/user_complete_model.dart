class UserCompleteModel {
  final int id;
  final String name;
  final String? lastname;
  final String email;
  final String? phone;
  final String? address;
  final String? gender;
  final String? ministry;
  final String? maritalstatus;
  final String? role;

  UserCompleteModel({
    required this.id,
    required this.name,
    this.lastname,
    required this.email,
    this.phone,
    this.address,
    this.gender,
    this.ministry,
    this.maritalstatus,
    this.role,
  });

  factory UserCompleteModel.fromJson(Map<String, dynamic> json) {
    return UserCompleteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastname: json['lastname'],
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      gender: json['gender'],
      ministry: json['ministry'],
      maritalstatus: json['maritalstatus'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'ministry': ministry,
      'maritalstatus': maritalstatus,
      'role': role,
    };
  }

  // Helper method to get full name
  String get fullName => '$name ${lastname ?? ''}'.trim();

  // Copy with method for updating user data
  UserCompleteModel copyWith({
    int? id,
    String? name,
    String? lastname,
    String? email,
    String? phone,
    String? address,
    String? gender,
    String? ministry,
    String? maritalstatus,
    String? role,
  }) {
    return UserCompleteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      maritalstatus: maritalstatus ?? this.maritalstatus,
      role: role ?? this.role,
    );
  }
}

// Enums para valores constantes
enum Gender {
  male,
  female,
  other
}

enum MaritalStatus {
  single,
  married,
  divorced,
  widowed
}

enum UserRole {
  USER,
  ADMIN,
  LEADER
}

extension GenderExtension on String {
  Gender? toGender() {
    return Gender.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == this.toLowerCase(),
      orElse: () => Gender.other,
    );
  }
}

extension MaritalStatusExtension on String {
  MaritalStatus? toMaritalStatus() {
    return MaritalStatus.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == this.toLowerCase(),
      orElse: () => MaritalStatus.single,
    );
  }
}