import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/models/book_model.dart';
import 'package:bibliotechmobile/core/models/publisher_model.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/admin/services/admin_service.dart';
import 'package:bibliotechmobile/modules/admin/widgets/admin_widgets.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

// Tela de gestão do acervo de livros e vínculo com editoras
class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<BookModel> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _books = await AdminService.getBooks();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  //modal de cadastro/edição carregando as editoras para vínculo
  Future<void> _openForm([BookModel? book]) async {
    List<PublisherModel> publishers = [];
    try {
      publishers = await AdminService.getPublishers();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
      return;
    }

    if (publishers.isEmpty) {
      if (mounted) showAuthSnack(context, 'Cadastre uma editora antes de adicionar livros.', isError: true);
      return;
    }
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: book?.title);
    final authorCtrl = TextEditingController(text: book?.author);
    final dateCtrl = TextEditingController(text: book != null ? formatBrDate(book.releaseDate) : '');
    final totalCtrl = TextEditingController(text: book?.totalQuantity.toString() ?? '');
    DateTime? releaseDate = book != null ? DateTime.tryParse(book.releaseDate) : null;
    int selectedPubId = (book != null && publishers.any((p) => p.id == book.publisherId))
        ? book.publisherId
        : publishers.first.id;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            book == null ? 'Cadastrar Livro' : 'Editar Livro',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthField(
                    label: 'Título',
                    hint: 'Título do livro',
                    controller: titleCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AuthField(
                          label: 'Autor',
                          hint: 'Nome do autor',
                          controller: authorCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AuthField(
                          label: 'Lançamento',
                          hint: 'DD/MM/AAAA',
                          controller: dateCtrl,
                          readOnly: true,
                          suffixIcon: const Icon(Icons.calendar_today, size: 16),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: releaseDate ?? DateTime.now(),
                              firstDate: DateTime(1500),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                releaseDate = picked;
                                dateCtrl.text =
                                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                              });
                            }
                          },
                          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AuthField(
                          label: 'Total',
                          hint: 'Qtd. total',
                          controller: totalCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) => (int.tryParse(v ?? '') == null || int.parse(v!) < 0) ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AuthField(
                          label: 'Em uso',
                          hint: '0',
                          controller: TextEditingController(text: '${book?.inUseQuantity ?? 0}'),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Editora', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: selectedPubId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: publishers
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedPubId = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: kSidebarColor, foregroundColor: Colors.white),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuthButton(
                    text: 'Confirmar',
                    isLoading: saving,
                    onPressed: () async {
                      if (!formKey.currentState!.validate() || releaseDate == null) return;
                      setModalState(() => saving = true);
                      try {
                        await AdminService.saveBook({
                          'title': titleCtrl.text.trim(),
                          'author': authorCtrl.text.trim(),
                          'releaseDate': releaseDate!.toIso8601String().split('T').first,
                          'totalQuantity': int.parse(totalCtrl.text.trim()),
                          'publisherId': selectedPubId,
                        }, id: book?.id);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        showAuthSnack(context, 'Livro salvo com sucesso!');
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

  // Exibe os dados completos de um livro
  Future<void> _showDetails(int id) async {
    try {
      final b = await AdminService.getBookById(id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(b.title),
          content: Text(
            'Autor: ${b.author}\n'
            'Editora: ${b.publisherName}\n'
            'Lançamento: ${formatBrDate(b.releaseDate)}\n'
            'Total: ${b.totalQuantity} | Em uso: ${b.inUseQuantity}',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
        ),
      );
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  Future<void> _delete(BookModel b) async {
    if (!await confirmDeleteDialog(context, b.title)) return;
    try {
      await AdminService.deleteBook(b.id);
      if (mounted) showAuthSnack(context, 'Livro excluído.');
      _load();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AppRoutes.adminBooks,
      actionLabel: 'Novo livro',
      onAction: () => _openForm(),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (_, i) {
                  final b = _books[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: () => _showDetails(b.id),
                      title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${b.author} • ${b.publisherName}\n'
                        'Lanç.: ${formatBrDate(b.releaseDate)} | Total: ${b.totalQuantity} | Em uso: ${b.inUseQuantity}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                            onPressed: () => _openForm(b),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                            onPressed: () => _delete(b),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}