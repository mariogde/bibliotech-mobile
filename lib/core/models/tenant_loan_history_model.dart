class TenantLoanHistoryModel {
  final int id;
  final String bookTitle;
  final String loanDate;
  final String dueDate;
  final String status;

  TenantLoanHistoryModel({
    required this.id,
    required this.bookTitle,
    required this.loanDate,
    required this.dueDate,
    required this.status,
  });

  factory TenantLoanHistoryModel.fromJson(Map<String, dynamic> json) =>
      TenantLoanHistoryModel(
        id: json['id'] ?? 0,
        bookTitle: json['bookTitle'] ?? '',
        loanDate: json['loanDate'] ?? '',
        dueDate: json['dueDate'] ?? '',
        status: json['status'] ?? '',
      );
}