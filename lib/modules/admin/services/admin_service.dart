import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bibliotechmobile/core/models/user_model.dart';
import 'package:bibliotechmobile/core/services/http/api_client.dart';
import 'package:bibliotechmobile/core/models/publisher_model.dart';
import 'package:bibliotechmobile/core/models/book_model.dart';
import 'package:bibliotechmobile/core/models/loan_model.dart';


// Operações de CRUD para admin
class AdminService {
  // Valida o status HTTP e extrai a mensagem de erro do backend se algo falhar
  static dynamic _parse(http.Response res, String fallback) {
    final body = res.body.isNotEmpty ? jsonDecode(utf8.decode(res.bodyBytes)) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception((body is Map ? (body['detail'] ?? body['message']) : null) ?? fallback);
  }

  //editoras
  static Future<List<PublisherModel>> getPublishers() async {
    final list = _parse(await ApiClient.get('/publishers'), 'Erro ao listar editoras.') as List;
    return list.map((e) => PublisherModel.fromJson(e)).toList();
  }

  static Future<PublisherModel> getPublisherById(int id) async =>
      PublisherModel.fromJson(_parse(await ApiClient.get('/publishers/$id'), 'Erro ao consultar editora.'));

  static Future<void> savePublisher(Map<String, dynamic> data, {int? id}) async {
    final res = id == null ? await ApiClient.post('/publishers', data) : await ApiClient.put('/publishers/$id', data);
    _parse(res, 'Erro ao salvar editora.');
  }

  static Future<void> deletePublisher(int id) async =>
      _parse(await ApiClient.delete('/publishers/$id'), 'Erro ao excluir editora.');

  //livros
  static Future<List<BookModel>> getBooks() async {
    final list = _parse(await ApiClient.get('/books'), 'Erro ao listar livros.') as List;
    return list.map((e) => BookModel.fromJson(e)).toList();
  }

  static Future<BookModel> getBookById(int id) async =>
      BookModel.fromJson(_parse(await ApiClient.get('/books/$id'), 'Erro ao consultar livro.'));

  static Future<void> saveBook(Map<String, dynamic> data, {int? id}) async {
    final res = id == null ? await ApiClient.post('/books', data) : await ApiClient.put('/books/$id', data);
    _parse(res, 'Erro ao salvar livro.');
  }

  static Future<void> deleteBook(int id) async =>
      _parse(await ApiClient.delete('/books/$id'), 'Erro ao excluir livro.');

  //alugueis
  static Future<List<UserModel>> getUsers() async {
    final list = _parse(await ApiClient.get('/users'), 'Erro ao listar locatários.') as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  static Future<List<LoanModel>> getLoans() async {
    final list = _parse(await ApiClient.get('/loans'), 'Erro ao listar aluguéis.') as List;
    return list.map((e) => LoanModel.fromJson(e)).toList();
  }

  static Future<LoanModel> getLoanById(int id) async =>
      LoanModel.fromJson(_parse(await ApiClient.get('/loans/$id'), 'Erro ao consultar aluguel.'));

  static Future<void> createLoan(String userCpf, String bookTitle) async {
    _parse(
      await ApiClient.post('/loans', {'userCpf': userCpf, 'bookTitle': bookTitle}),
      'Erro ao registrar aluguel.',
    );
  }

  static Future<void> returnLoan(int id) async =>
      _parse(await ApiClient.patch('/loans/$id/return'), 'Erro ao registrar devolução.');

  static Future<void> deleteLoan(int id) async =>
      _parse(await ApiClient.delete('/loans/$id'), 'Erro ao excluir aluguel.');
}