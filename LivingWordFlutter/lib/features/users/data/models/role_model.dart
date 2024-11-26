class Role {
  final int id;
  final String name;
  final int level;
  final List<String> permissions;

  Role({
    required this.id,
    required this.name,
    required this.level,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      permissions: List<String>.from(json['permissions']),
    );
  }
}