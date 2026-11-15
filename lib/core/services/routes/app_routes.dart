import 'package:flutter/material.dart';
import 'package:bibliotechmobile/modules/auth/pages/forgot_password_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/login_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/register_page.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const adminDashboard = '/dashboard/admin';
  static const userDashboard = '/dashboard/user';


  // Proteção de rotas para admin e usuário
  static Widget _protected(Widget page, {bool adminOnly = false}) {
    final user = AuthService.currentUser;
    if (user == null || (adminOnly && !user.isAdmin)) {
      return const LoginPage();
    }
    return page;
  }
  // Associação de rotas com suas respectivas páginas
  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        adminDashboard: (_) => _protected(
              const Scaffold(body: Center(child: Text('Dashboard do Administrador'))),
              adminOnly: true,
            ),
        userDashboard: (_) => _protected(
              const Scaffold(body: Center(child: Text('Dashboard do Usuário'))),
            ),
      };
}