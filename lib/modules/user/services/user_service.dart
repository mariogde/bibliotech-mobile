import 'dart:convert';
import 'package:bibliotechmobile/core/models/tenant_loan_history_model.dart';
import 'package:bibliotechmobile/core/models/user_model.dart';
import 'package:bibliotechmobile/core/services/http/api_client.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';

// Centraliza as consultas HTTP exclusivas da área do locatário
class UserService {
  // Busca o histórico de empréstimos apenas do locatário logado
  static Future<List<TenantLoanHistoryModel>> getMyLoanHistory() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    final res = await ApiClient.get('/loans/user/$userId');
    final body = res.body.isNotEmpty ? jsonDecode(utf8.decode(res.bodyBytes)) : null;

    if (res.statusCode >= 200 && res.statusCode < 300 && body is List) {
      return body.map((e) => TenantLoanHistoryModel.fromJson(e)).toList();
    }
    throw Exception((body is Map ? (body['detail'] ?? body['message']) : null) ?? 'Erro ao carregar histórico.');
  }

  // Atualiza os 4 campos permitidos pelo UserUpdateDTO via PUT /users/me
  static Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final payload = {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };

    final res = await ApiClient.put('/users/me', payload);
    final body = res.body.isNotEmpty ? jsonDecode(utf8.decode(res.bodyBytes)) : null;

    if (res.statusCode >= 200 && res.statusCode < 300 && body is Map<String, dynamic>) {
      final updated = UserModel.fromJson(body);
      AuthService.currentUser = updated;
      return updated;
    }
    throw Exception((body is Map ? (body['detail'] ?? body['message']) : null) ?? 'Erro ao atualizar perfil.');
  }
}