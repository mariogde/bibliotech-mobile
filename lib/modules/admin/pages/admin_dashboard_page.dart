import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/admin/widgets/admin_widgets.dart';

// Tela inicial de admin
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminScaffold(
      currentRoute: AppRoutes.adminDashboard,
      child: Center(
        child: Text(
          'mostragem de dados gerais da biblioteca',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
    );
  }
}