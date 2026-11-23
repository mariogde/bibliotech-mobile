import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';
import 'package:bibliotechmobile/modules/user/services/user_service.dart';
import 'package:bibliotechmobile/modules/user/widgets/user_widgets.dart';

// Tela de visualização e edição dos dados cadastrais do locatário logado
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cpfCtrl;
  late final TextEditingController _birthCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
    _cpfCtrl = TextEditingController(text: u?.cpf ?? '');
    _birthCtrl = TextEditingController(text: formatTenantDate(u?.dateOfBirth));
    _addressCtrl = TextEditingController(text: u?.address ?? '');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _cpfCtrl, _birthCtrl, _addressCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await UserService.updateProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
      if (!mounted) return;
      showAuthSnack(context, 'Dados atualizados com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = AuthService.currentUser?.name ?? 'Locatário';

    return UserScaffold(
      currentRoute: AppRoutes.userProfile,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 28, color: Color(0xFF4A4F55)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AuthField(
                  label: 'Nome Completo',
                  hint: 'Seu nome completo',
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome.' : null,
                ),
                const SizedBox(height: 12),
                AuthField(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido.' : null,
                ),
                const SizedBox(height: 12),
                AuthField(
                  label: 'Telefone',
                  hint: '(88) 99999-9999',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o telefone.' : null,
                ),
                const SizedBox(height: 12),
                AuthField(
                  label: 'CPF (não editável)',
                  hint: '',
                  controller: _cpfCtrl,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                AuthField(
                  label: 'Data de nascimento (não editável)',
                  hint: '',
                  controller: _birthCtrl,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                AuthField(
                  label: 'Endereço',
                  hint: 'Rua, número, bairro',
                  controller: _addressCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o endereço.' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthButton(
                        text: 'Confirmar',
                        isLoading: _saving,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}