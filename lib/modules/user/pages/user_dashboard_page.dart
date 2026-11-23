import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/models/tenant_loan_history_model.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';
import 'package:bibliotechmobile/modules/user/services/user_service.dart';
import 'package:bibliotechmobile/modules/user/widgets/user_widgets.dart';

// Tela inicial da área do locatário com resumo de posse, atrasos e aluguéis vigentes
class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
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

  bool _isReturned(String status) {
    final s = status.toUpperCase();
    return s.contains('RETURN') || s.contains('DEVOLV') || s.contains('ENTREGUE');
  }

  bool _isLate(String status) {
    final s = status.toUpperCase();
    return s.contains('LATE') || s.contains('OVERDUE') || s.contains('ATRAS');
  }

  // Retorna o título mais recorrente no histórico do locatário
  String _mostRentedBook() {
    if (_loans.isEmpty) return '-';
    final counts = <String, int>{};
    for (final l in _loans) {
      counts[l.bookTitle] = (counts[l.bookTitle] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Widget _statCard(String label, String value, {String? subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLoans = _loans.where((l) => !_isReturned(l.status)).toList();
    final lateCount = activeLoans.where((l) => _isLate(l.status)).length;
    final lastLoan = _loans.isNotEmpty ? _loans.first : null;

    return UserScaffold(
      currentRoute: AppRoutes.userDashboard,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(child: _statCard('Livros em posse', '${activeLoans.length}')),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard('Em atraso', '$lateCount')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _statCard(
                    'Último livro alugado',
                    lastLoan?.bookTitle ?? 'Nenhum',
                    subtitle: lastLoan != null ? 'Retirada: ${formatTenantDate(lastLoan.loanDate)}' : null,
                  ),
                  const SizedBox(height: 10),
                  _statCard('Livro mais alugado', _mostRentedBook()),
                  const SizedBox(height: 18),
                  const Text('Aluguéis vigentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  if (activeLoans.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Nenhum aluguel ativo no momento.')),
                    )
                  else
                    ...activeLoans.map((item) {
                      final late = _isLate(item.status);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Devolução prevista: ${formatTenantDate(item.dueDate)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: late ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              late ? 'Atrasado' : 'Alugado',
                              style: TextStyle(
                                color: late ? Colors.red.shade800 : Colors.green.shade900,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}