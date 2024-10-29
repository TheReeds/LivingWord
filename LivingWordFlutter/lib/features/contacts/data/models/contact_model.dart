class ContactModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final int? addedById;
  final String? addedByName;
  final String? addedByLastname;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.addedById,
    this.addedByName,
    this.addedByLastname,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      addedById: json['addedById'],
      addedByName: json['addedByName'],
      addedByLastname: json['addedByLastname'],
    );
  }
}
