import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/models/tenant_loan_history_model.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';
import 'package:bibliotechmobile/modules/user/services/user_service.dart';
import 'package:bibliotechmobile/modules/user/widgets/user_widgets.dart';

// Tela que exibe o histórico completo de empréstimos do locatário logado
class TenantLoansPage extends StatefulWidget {
  const TenantLoansPage({super.key});

  @override
  State<TenantLoansPage> createState() => _TenantLoansPageState();
}

class _TenantLoansPageState extends State<TenantLoansPage> {
  List<TenantLoanHistoryModel> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _loans = await UserService.getMyLoanHistory();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Mapeia o LoanStatus retornado pelo backend para o rótulo e cor do protótipo
  (String, Color, Color) _statusStyle(String status) {
    final s = status.toUpperCase();
    if (s.contains('LATE') || s.contains('OVERDUE') || s.contains('ATRAS')) {
      return ('Atrasado', Colors.red.shade100, Colors.red.shade800);
    }
    if (s.contains('RETURN') || s.contains('DEVOLV') || s.contains('ENTREGUE')) {
      return ('Entregue no prazo', Colors.grey.shade200, Colors.black87);
    }
    return ('Alugado', Colors.green.shade100, Colors.green.shade900);
  }

  @override
  Widget build(BuildContext context) {
    return UserScaffold(
      currentRoute: AppRoutes.userLoans,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meus empréstimos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 12),
                Expanded(
                  child: _loans.isEmpty
                      ? const Center(child: Text('Você ainda não possui empréstimos registrados.'))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _loans.length,
                            itemBuilder: (_, i) {
                              final item = _loans[i];
                              final (label, bg, fg) = _statusStyle(item.status);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  title: Text(item.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    'Retirada: ${formatTenantDate(item.loanDate)}\n'
                                    'Devolução prevista: ${formatTenantDate(item.dueDate)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}