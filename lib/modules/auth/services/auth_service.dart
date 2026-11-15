import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bibliotechmobile/core/models/user_model.dart';
import 'package:bibliotechmobile/core/services/http/api_client.dart';

class AuthService {
  static UserModel? currentUser;


  // Trata mensagens de erro
  static Never _throwError(http.Response res, String fallback) {
    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    throw Exception(data['detail'] ?? data['message'] ?? fallback);
  }

  // Autentica usuário e retorna o modelo de usuário
  static Future<UserModel> login(String email, String password) async {
    final res = await ApiClient.post('/auth/login', {'email': email, 'password': password});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map && data['token'] != null) {
        ApiClient.token = data['token'];
      }

      final userJson = (data is Map && data['user'] != null) ? data['user'] : data;
      currentUser = UserModel.fromJson(userJson);

      if (currentUser!.isDisabled) {
        throw Exception('Conta de usuário desativada.');
      }
      return currentUser!;
    }

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('E-mail ou senha inválidos.');
    }
    _throwError(res, 'Erro ao realizar login.');
  }

  // Cadastra um novo usuário
  static Future<void> register(Map<String, dynamic> userData) async {
    final res = await ApiClient.post('/users', userData);
    if (res.statusCode != 201 && res.statusCode != 200) {
      _throwError(res, 'Erro ao cadastrar usuário.');
    }
  }

  // Valida os dados para recuperação de senha
  static Future<void> validatePasswordRecovery(String email, String cpf) async {
    final res = await ApiClient.post('/auth/forgot-password/validate', {
      'email': email,
      'cpf': cpf,
    });
    if (res.statusCode != 200) {
      _throwError(res, 'E-mail ou CPF não encontrados.');
    }
  }

  // Redefine a senha do usuário
  static Future<void> resetPassword(
    String email,
    String cpf,
    String newPassword,
    String confirmPassword,
  ) async {
    final res = await ApiClient.put('/auth/forgot-password/reset', {
      'email': email,
      'cpf': cpf,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
    if (res.statusCode != 204 && res.statusCode != 200) {
      _throwError(res, 'Erro ao redefinir a senha.');
    }
  }

  // Encerra a sessão do usuário
  static void logout() {
    currentUser = null;
    ApiClient.token = null;
  }
}