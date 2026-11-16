class BookModel {
  final int id;
  final String title;
  final String author;
  final String releaseDate;
  final int totalQuantity;
  final int inUseQuantity;
  final int publisherId;
  final String publisherName;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.releaseDate,
    required this.totalQuantity,
    required this.inUseQuantity,
    required this.publisherId,
    required this.publisherName,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final pub = json['publisher'] as Map<String, dynamic>?;
    return BookModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      inUseQuantity: json['inUseQuantity'] ?? 0,
      publisherId: pub?['id'] ?? 0,
      publisherName: pub?['name'] ?? '',
    );
  }
}