class PublisherModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String website;

  PublisherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
  });

  factory PublisherModel.fromJson(Map<String, dynamic> json) => PublisherModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        website: json['website'] ?? '',
      );
}