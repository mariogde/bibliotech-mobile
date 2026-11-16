import 'package:flutter/material.dart';
import 'package:bibliotechmobile/modules/admin/pages/admin_dashboard_page.dart';
import 'package:bibliotechmobile/modules/admin/pages/books_page.dart';
import 'package:bibliotechmobile/modules/admin/pages/loans_page.dart';
import 'package:bibliotechmobile/modules/admin/pages/publishers_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/forgot_password_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/login_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/register_page.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';

// Mapeia as rotas de navegação
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const adminDashboard = '/dashboard/admin';
  static const adminPublishers = '/admin/publishers';
  static const adminBooks = '/admin/books';
  static const adminLoans = '/admin/loans';
  static const userDashboard = '/dashboard/user';

  // Proteção ao acesso às telas internas se o usuário não estiver logado ou não for admin
  static Widget _protected(Widget page, {bool adminOnly = false}) {
    final user = AuthService.currentUser;
    if (user == null || (adminOnly && !user.isAdmin)) {
      return const LoginPage();
    }
    return page;
  }

  // Associa cada caminho textual ao seu respectivo widget de tela
  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        adminDashboard: (_) => _protected(const AdminDashboardPage(), adminOnly: true),
        adminPublishers: (_) => _protected(const PublishersPage(), adminOnly: true),
        adminBooks: (_) => _protected(const BooksPage(), adminOnly: true),
        adminLoans: (_) => _protected(const LoansPage(), adminOnly: true),
        userDashboard: (_) => _protected(
              const Scaffold(body: Center(child: Text('Dashboard do Usuário'))),
            ),
      };
}