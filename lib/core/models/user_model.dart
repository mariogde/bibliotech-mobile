class UserModel {
  final int id;
  final String name;
  final String email;
  final String? cpf;
  final String? phone;
  final String? address;
  final bool isAdmin;
  final bool isDisabled;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.cpf,
    this.phone,
    this.address,
    required this.isAdmin,
    required this.isDisabled,
  });

  //conversão de JSON para UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        cpf: json['cpf'],
        phone: json['phone'],
        address: json['address'],
        isAdmin: json['admin'] ?? json['isAdmin'] ?? false,
        isDisabled: json['disabled'] ?? json['isDisabled'] ?? false,
      );
}