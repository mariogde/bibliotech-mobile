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
    final body = res.body.isNotEmpty ? jsonDecode(utf8.decode(res.bodyBytes)) : null;

    if (res.statusCode >= 200 && res.statusCode < 300 && body is Map<String, dynamic>) {
      ApiClient.token = body['token'] ?? body['accessToken'];

      Map<String, dynamic> userData = Map<String, dynamic>.from(body);

      // Se o login não trouxe o id numérico, busca pelo e-mail na listagem de usuários
      if (userData['id'] == null || userData['id'] == 0) {
        final usersRes = await ApiClient.get('/users');
        if (usersRes.statusCode >= 200 && usersRes.statusCode < 300 && usersRes.body.isNotEmpty) {
          final usersList = jsonDecode(utf8.decode(usersRes.bodyBytes));
          if (usersList is List) {
            for (final u in usersList) {
              if (u is Map<String, dynamic> &&
                  (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase()) {
                userData = u;
                break;
              }
            }
          }
        }
      }

      final user = UserModel.fromJson(userData);
      if (user.isDisabled) {
        logout();
        throw Exception('Esta conta está desativada. Contate o administrador.');
      }
      currentUser = user;
      return user;
    }
    throw Exception((body is Map ? (body['detail'] ?? body['message']) : null) ?? 'E-mail ou senha inválidos.');
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