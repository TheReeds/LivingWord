class UserModel {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String role;
  final List<String> permissions;
  final String ministry;
  final String token;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.role,
    required this.permissions,
    required this.ministry,
    required this.token,
    required this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      ministry: json['ministry'] ?? '',
      token: json['token'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
    );
  }

}