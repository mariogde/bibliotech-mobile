import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/models/book_model.dart';
import 'package:bibliotechmobile/core/models/loan_model.dart';
import 'package:bibliotechmobile/core/models/user_model.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/admin/services/admin_service.dart';
import 'package:bibliotechmobile/modules/admin/widgets/admin_widgets.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

// Tela de histórico, registro, devolução e exclusão de empréstimos (aluguéis)
class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  List<LoanModel> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _loans = await AdminService.getLoans();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Traduz o enum LoanStatus do backend para o rótulo e cor do protótipo
  (String, Color, Color) _statusStyle(String status) {
    final s = status.toUpperCase();
    if (s.contains('LATE') || s.contains('OVERDUE') || s.contains('ATRAS')) {
      return ('Atrasado', Colors.red.shade100, Colors.red.shade800);
    }
    if (s.contains('RETURN') || s.contains('DEVOLV') || s.contains('ENTREGUE')) {
      return ('Entregue', Colors.grey.shade200, Colors.black87);
    }
    return ('Alugado', Colors.green.shade100, Colors.green.shade900);
  }

  // Abre o modal de cadastro de aluguel selecionando o livro e o locatário (CPF)
  Future<void> _openCreateModal() async {
    List<BookModel> books = [];
    List<UserModel> users = [];
    try {
      books = await AdminService.getBooks();
      users = (await AdminService.getUsers()).where((u) => !u.isAdmin && !u.isDisabled && u.cpf != null).toList();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
      return;
    }

    if (books.isEmpty || users.isEmpty) {
      if (mounted) showAuthSnack(context, 'É necessário ter livros e locatários cadastrados.', isError: true);
      return;
    }
    if (!mounted) return;

    int selectedBookId = books.first.id;
    String selectedUserCpf = users.first.cpf!;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Cadastro de aluguel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Livro', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: selectedBookId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: books
                    .map((b) => DropdownMenuItem<int>(
                          value: b.id,
                          child: Text('${b.title} (${b.author})', overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedBookId = v!),
              ),
              const SizedBox(height: 14),
              const Text('Locatário', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedUserCpf,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: users
                    .map((u) => DropdownMenuItem<String>(
                          value: u.cpf!,
                          child: Text('${u.name} (${u.cpf})', overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedUserCpf = v!),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuthButton(
                    text: 'Confirmar',
                    isLoading: saving,
                    onPressed: () async {
                      setModalState(() => saving = true);
                      try {
                        final selectedBook = books.firstWhere((b) => b.id == selectedBookId);
                        await AdminService.createLoan(selectedUserCpf, selectedBook.title);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        showAuthSnack(context, 'Aluguel registrado com sucesso!');
                        _load();
                      } catch (e) {
                        setModalState(() => saving = false);
                        if (mounted) showAuthSnack(context, e.toString(), isError: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Consulta os detalhes do empréstimo por ID na API
  Future<void> _showDetails(int id) async {
    try {
      final l = await AdminService.getLoanById(id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.book.title),
          content: Text(
            'Locatário: ${l.user.name} (${l.user.cpf ?? '-'})\n'
            'Data do aluguel: ${formatBrDate(l.loanDate)}\n'
            'Devolução prevista: ${formatBrDate(l.dueDate)}\n'
            'Devolução efetiva: ${formatBrDate(l.returnDate)}\n'
            'Status: ${l.status}',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
        ),
      );
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  // Registra a devolução do livro via PATCH /loans/{id}/return
  Future<void> _returnBook(LoanModel loan) async {
    try {
      await AdminService.returnLoan(loan.id);
      if (mounted) showAuthSnack(context, 'Devolução registrada com sucesso!');
      _load();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  Future<void> _delete(LoanModel loan) async {
    if (!await confirmDeleteDialog(context, '${loan.book.title} - ${loan.user.name}')) return;
    try {
      await AdminService.deleteLoan(loan.id);
      if (mounted) showAuthSnack(context, 'Registro excluído.');
      _load();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AppRoutes.adminLoans,
      actionLabel: 'Novo aluguel',
      onAction: _openCreateModal,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Histórico de aluguéis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                const Text(
                  'Registros de aluguel são definitivos e seguem as regras de devolução da API.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: _loans.length,
                      itemBuilder: (_, i) {
                        final l = _loans[i];
                        final (label, bg, fg) = _statusStyle(l.status);
                        final isReturned = l.returnDate != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () => _showDetails(l.id),
                            title: Text(l.book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Locatário: ${l.user.name}\n'
                              'Aluguel: ${formatBrDate(l.loanDate)} • Prev.: ${formatBrDate(l.dueDate)}',
                            ),
                            isThreeLine: true,
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                                  child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                if (!isReturned)
                                  IconButton(
                                    tooltip: 'Registrar devolução',
                                    icon: const Icon(Icons.assignment_return_outlined, color: kPrimaryColor),
                                    onPressed: () => _returnBook(l),
                                  ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                                  onPressed: () => _delete(l),
                                ),
                              ],
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