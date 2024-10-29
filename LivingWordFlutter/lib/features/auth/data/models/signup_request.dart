import '../repositories/auth_repository.dart';

class SignupRequest {
  final String name;
  final String lastname;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String dateBirth;
  final String maritalstatus;
  final String gender;
  final String role;

  SignupRequest({
    required this.name,
    required this.lastname,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.dateBirth,
    required this.maritalstatus,
    required this.gender,
  }) : role = "USER"; // Siempre será USER

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'dateBirth': dateBirth,
      'maritalstatus': maritalstatus,
      'gender': gender,
      'role': role,
    };
  }
}