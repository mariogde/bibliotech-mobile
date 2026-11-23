class UserModel {
  final int id;
  final String name;
  final String email;
  final String? cpf;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final bool isAdmin;
  final bool isDisabled;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.cpf,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.isAdmin = false,
    this.isDisabled = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        cpf: json['cpf'],
        phone: json['phone'],
        dateOfBirth: json['dateOfBirth'] ?? json['birthDate'],
        address: json['address'],
        isAdmin: json['admin'] == true || json['role'] == 'ADMIN',
        isDisabled: json['disabled'] == true || json['active'] == false,
      );
}