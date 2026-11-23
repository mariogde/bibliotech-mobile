import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

const kUserSidebarColor = Color(0xFF262A2E);
const kUserSidebarHeaderColor = Color(0xFF3A3F45);

// Estrutura padrão das telas do locatário com AppBar, perfil clicável e Drawer lateral
class UserScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const UserScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  // Exibe o modal de confirmação de saída do sistema
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sair do sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: const Text('Deseja encerrar sua sessão?', style: TextStyle(fontSize: 14)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AuthService.logout();
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, String route) {
    final active = currentRoute == route;
    return ListTile(
      tileColor: active ? Colors.grey.shade300 : Colors.transparent,
      title: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: active ? Colors.black87 : Colors.white,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!active) Navigator.pushReplacementNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.currentUser?.name ?? 'Locatário';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          InkWell(
            onTap: () {
              if (currentRoute != AppRoutes.userProfile) {
                Navigator.pushNamed(context, AppRoutes.userProfile);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(0xFF4A4F55),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: kUserSidebarColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: kUserSidebarHeaderColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'BiblioTech',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _navItem(context, 'Dashboard', AppRoutes.userDashboard),
              _navItem(context, 'Histórico de alugueis', AppRoutes.userLoans),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sair', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// Formata datas ISO (yyyy-MM-dd) para o padrão brasileiro (dd/MM/yyyy)
String formatTenantDate(String? iso) {
  if (iso == null || !iso.contains('-')) return iso ?? '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}