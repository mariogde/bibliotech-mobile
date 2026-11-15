import 'package:flutter/material.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _stepTwo = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  // Limpa os controladores ao descartar o widget
  @override
  void dispose() {
    for (final c in [_emailCtrl, _cpfCtrl, _newPassCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // Valida o formulário e realiza a recuperação de senha
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final cpf = _cpfCtrl.text.trim();

      if (!_stepTwo) {
        await AuthService.validatePasswordRecovery(email, cpf);
        if (mounted) setState(() => _stepTwo = true);
      } else {
        await AuthService.resetPassword(email, cpf, _newPassCtrl.text, _confirmCtrl.text);
        if (!mounted) return;
        showAuthSnack(context, 'Senha redefinida com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Botão para alternar a visibilidade da senha
  Widget _eyeButton(bool obscure, VoidCallback toggle) => IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade600),
        onPressed: toggle,
      );

  // Montagem do formulário de recuperação de senha
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        subtitle: 'Recuperar Senha de acesso',
        children: [
          if (!_stepTwo) ...[
            AuthField(
              label: 'E-mail',
              hint: 'Digite seu e-mail',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
            ),
            const SizedBox(height: 16),
            AuthField(
              label: 'CPF',
              hint: 'Digite seu CPF',
              controller: _cpfCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu CPF' : null,
            ),
          ] else ...[
            AuthField(
              label: 'Nova senha',
              hint: '8 a 15 caracteres',
              controller: _newPassCtrl,
              obscureText: _obscureNew,
              suffixIcon: _eyeButton(_obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
              validator: (v) => (v == null || v.length < 8 || v.length > 15) ? 'Entre 8 e 15 caracteres' : null,
            ),
            const SizedBox(height: 16),
            AuthField(
              label: 'Confirmar senha',
              hint: 'Confirme a nova senha',
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              suffixIcon: _eyeButton(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
              validator: (v) => (v != _newPassCtrl.text) ? 'As senhas não coincidem' : null,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AuthButton(
                  text: 'Cancelar',
                  secondary: true,
                  onPressed: () => _stepTwo ? setState(() => _stepTwo = false) : Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: AuthButton(text: 'Confirmar', isLoading: _loading, onPressed: _submit)),
            ],
          ),
        ],
      ),
    );
  }
}