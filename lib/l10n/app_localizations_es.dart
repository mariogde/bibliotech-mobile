// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BiblioTech';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'Ingrese su correo electrónico';

  @override
  String get emailRequired => 'Ingrese el correo electrónico';

  @override
  String get emailInvalid => 'Ingrese un correo válido';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHint => 'Ingrese su contraseña';

  @override
  String get passwordRequired => 'Ingrese la contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get registerNow => 'Regístrese ahora';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';
}
