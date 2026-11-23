import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/models/publisher_model.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/admin/services/admin_service.dart';
import 'package:bibliotechmobile/modules/admin/widgets/admin_widgets.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

// Tela de listagem, consulta, cadastro, edição e exclusão de editoras
class PublishersPage extends StatefulWidget {
  const PublishersPage({super.key});

  @override
  State<PublishersPage> createState() => _PublishersPageState();
}

class _PublishersPageState extends State<PublishersPage> {
  List<PublisherModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await AdminService.getPublishers();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Modal de cadastro ou edição de uma editora
  Future<void> _openForm([PublisherModel? item]) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: item?.name);
    final emailCtrl = TextEditingController(text: item?.email);
    final phoneCtrl = TextEditingController(text: item?.phone);
    final siteCtrl = TextEditingController(text: item?.website);
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            item == null ? 'Cadastrar Editora' : 'Editar Editora',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthField(
                    label: 'Nome completo',
                    hint: 'Nome da editora',
                    controller: nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AuthField(
                          label: 'E-mail',
                          hint: 'contato@editora.com',
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AuthField(
                          label: 'Telefone',
                          hint: '(11) 4000-0000',
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AuthField(
                    label: 'Site',
                    hint: 'editora.com',
                    controller: siteCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
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
                      if (!formKey.currentState!.validate()) return;
                      setModalState(() => saving = true);
                      try {
                        await AdminService.savePublisher({
                          'name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'website': siteCtrl.text.trim(),
                        }, id: item?.id);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        showAuthSnack(context, 'Editora salva com sucesso!');
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

  // Consulta os detalhes de editoras
  Future<void> _showDetails(int id) async {
    try {
      final p = await AdminService.getPublisherById(id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(p.name),
          content: Text('ID: ${p.id}\nE-mail: ${p.email}\nTelefone: ${p.phone}\nSite: ${p.website}'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
        ),
      );
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  Future<void> _delete(PublisherModel item) async {
    if (!await confirmDeleteDialog(context, item.name)) return;
    try {
      await AdminService.deletePublisher(item.id);
      if (mounted) showAuthSnack(context, 'Editora excluída.');
      _load();
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AppRoutes.adminPublishers,
      actionLabel: 'Nova editora',
      onAction: () => _openForm(),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final p = _items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: () => _showDetails(p.id),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.email} • ${p.phone}\n${p.website}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                            onPressed: () => _openForm(p),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                            onPressed: () => _delete(p),
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