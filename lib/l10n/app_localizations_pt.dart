// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'BiblioTech';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'Digite seu e-mail';

  @override
  String get emailRequired => 'Informe o e-mail';

  @override
  String get emailInvalid => 'Informe um e-mail válido';

  @override
  String get password => 'Senha';

  @override
  String get passwordHint => 'Digite sua senha';

  @override
  String get passwordRequired => 'Informe a senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get registerNow => 'Cadastre-se agora';

  @override
  String get forgotPassword => 'Esqueci a senha';
}
