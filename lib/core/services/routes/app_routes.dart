import 'package:flutter/material.dart';
import 'package:bibliotechmobile/modules/admin/pages/admin_dashboard_page.dart';
import 'package:bibliotechmobile/modules/admin/pages/books_page.dart';
import 'package:bibliotechmobile/modules/admin/pages/loans_page.dart';
import 'package:bibliotechmobile/modules/admin/pages/publishers_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/forgot_password_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/login_page.dart';
import 'package:bibliotechmobile/modules/auth/pages/register_page.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';
import 'package:bibliotechmobile/modules/user/pages/tenant_loans_page.dart';
import 'package:bibliotechmobile/modules/user/pages/user_dashboard_page.dart';
import 'package:bibliotechmobile/modules/user/pages/user_profile_page.dart';

// Mapeia todas as rotas de navegação do aplicativo e protege as telas restritas
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const adminDashboard = '/dashboard/admin';
  static const adminPublishers = '/admin/publishers';
  static const adminBooks = '/admin/books';
  static const adminLoans = '/admin/loans';
  static const userDashboard = '/dashboard/user';
  static const userLoans = '/user/loans';
  static const userProfile = '/user/profile';

  // Bloqueia o acesso às telas internas se o usuário não estiver logado ou não for admin
  static Widget _protected(Widget page, {bool adminOnly = false}) {
    final user = AuthService.currentUser;
    if (user == null) return const LoginPage();
    if (adminOnly && !user.isAdmin) return const UserDashboardPage();
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
        userDashboard: (_) => _protected(const UserDashboardPage()),
        userLoans: (_) => _protected(const TenantLoansPage()),
        userProfile: (_) => _protected(const UserProfilePage()),
      };
}