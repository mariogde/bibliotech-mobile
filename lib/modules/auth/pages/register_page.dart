import 'package:flutter/material.dart';
import 'package:bibliotechmobile/modules/auth/services/auth_service.dart';
import 'package:bibliotechmobile/modules/auth/widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  DateTime? _birthDate;
  bool _loading = false;

  // Limpa os controladores ao descartar o widget
  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _cpfCtrl, _dateCtrl, _phoneCtrl, _addressCtrl, _passCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // Abre o seletor de data para o campo de data de nascimento
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // Valida o formulário e realiza o cadastro
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _birthDate == null) return;
    setState(() => _loading = true);

    try {
      final address = _addressCtrl.text.trim();
      await AuthService.register({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'cpf': _cpfCtrl.text.trim(),
        'dateOfBirth': _birthDate!.toIso8601String().split('T').first,
        'phone': _phoneCtrl.text.trim(),
        'address': address.isEmpty ? null : address,
        'password': _passCtrl.text,
      });

      if (!mounted) return;
      showAuthSnack(context, 'Cadastro realizado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showAuthSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Montagem do formulário de cadastro
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        children: [
          AuthField(
            label: 'Nome Completo',
            hint: 'Digite seu nome completo',
            controller: _nameCtrl,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Obrigatório'
                : (v.trim().length > 50 ? 'Máximo 50 caracteres' : null),
          ),
          const SizedBox(height: 14),
          AuthField(
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@'))
                ? 'E-mail inválido'
                : (v.trim().length > 50 ? 'Máximo 50 caracteres' : null),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AuthField(
                  label: 'CPF',
                  hint: '000.000.000-00',
                  controller: _cpfCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().length < 11 || v.trim().length > 14) ? 'CPF inválido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthField(
                  label: 'Data de nascimento',
                  hint: 'DD/MM/AAAA',
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AuthField(
            label: 'Telefone',
            hint: '(00) 00000-0000',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Obrigatório'
                : (v.trim().length > 20 ? 'Máximo 20 caracteres' : null),
          ),
          const SizedBox(height: 14),
          AuthField(
            label: 'Endereço (opcional)',
            hint: 'Rua, número, bairro',
            controller: _addressCtrl,
            validator: (v) => (v != null && v.trim().length > 50) ? 'Máximo 50 caracteres' : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AuthField(
                  label: 'Senha',
                  hint: '8 a 15 chars',
                  controller: _passCtrl,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 8 || v.length > 15) ? '8 a 15 chars' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthField(
                  label: 'Confirmar Senha',
                  hint: 'Repita a senha',
                  controller: _confirmCtrl,
                  obscureText: true,
                  validator: (v) => (v != _passCtrl.text) ? 'Não coincide' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: AuthButton(text: 'Cancelar', secondary: true, onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: AuthButton(text: 'Cadastrar', isLoading: _loading, onPressed: _submit)),
            ],
          ),
        ],
      ),
    );
  }
}