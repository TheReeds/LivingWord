class User {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String ministry;
  final String address;
  final String gender;
  final String maritalstatus;
  final String role;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.ministry,
    required this.address,
    required this.gender,
    required this.maritalstatus,
    required this.role,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      ministry: json['ministry'],
      address: json['address'],
      gender: json['gender'],
      maritalstatus: json['maritalstatus'],
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
      'maritalstatus': maritalstatus,
    };
  }
}