// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Arrow POC';

  @override
  String get play => 'Jugar';

  @override
  String get settings => 'Configuracion';

  @override
  String get levels => 'Niveles';

  @override
  String get gamePlaceholder => 'Pantalla de juego provisional';

  @override
  String get backendUrlLabel => 'URL del backend';

  @override
  String get homeSubtitle =>
      'Base de rompecabezas con grafos para el juego movil.';

  @override
  String get levelSelectionPlaceholder => 'Seleccion de niveles provisional';

  @override
  String get settingsPlaceholder => 'Configuracion provisional';

  @override
  String get openGame => 'Abrir juego';
}
