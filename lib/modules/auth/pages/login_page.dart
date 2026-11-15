import 'package:flutter/material.dart';
import 'package:bibliotechmobile/core/services/routes/app_routes.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  // Limpa os controladores ao descartar o widget
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Valida o formulário e realiza o login
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        user.isAdmin ? AppRoutes.adminDashboard : AppRoutes.userDashboard,
      );
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Montagem do formulário de login
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        children: [
          AuthField(
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
          ),
          const SizedBox(height: 16),
          AuthField(
            label: 'Senha',
            hint: 'Digite sua senha',
            controller: _passCtrl,
            obscureText: _obscure,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
          ),
          const SizedBox(height: 24),
          AuthButton(text: 'Entrar', isLoading: _loading, onPressed: _submit),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 16,
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text('Cadastre-se agora', style: TextStyle(decoration: TextDecoration.underline)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                child: const Text('Esqueci a senha', style: TextStyle(decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}