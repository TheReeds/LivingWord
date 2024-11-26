class UserDetailsModel {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String? phone;
  final String? ministry;
  final String? address;
  final String? gender;
  final String? maritalStatus;
  final String role;
  final String? photoUrl;

  UserDetailsModel({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    this.phone,
    this.ministry,
    this.address,
    this.gender,
    this.maritalStatus,
    required this.role,
    this.photoUrl,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id'],
      name: json['name'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      ministry: json['ministry'],
      address: json['address'],
      gender: json['gender'],
      maritalStatus: json['maritalstatus'],
      role: json['role'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'address': address,
      'gender': gender,
      'maritalstatus': maritalStatus,
    };
  }
}