import 'package:bibliotechmobile/core/models/user_model.dart';
import 'package:bibliotechmobile/core/models/book_model.dart';

class LoanModel {
  final int id;
  final UserModel user;
  final BookModel book;
  final String loanDate;
  final String dueDate;
  final String? returnDate;
  final String status;

  LoanModel({
    required this.id,
    required this.user,
    required this.book,
    required this.loanDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'] ?? 0,
        user: UserModel.fromJson(json['user'] ?? {}),
        book: BookModel.fromJson(json['book'] ?? {}),
        loanDate: json['loanDate'] ?? '',
        dueDate: json['dueDate'] ?? '',
        returnDate: json['returnDate'],
        status: json['status'] ?? '',
      );
}