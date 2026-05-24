// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arrow POC';

  @override
  String get play => 'Play';

  @override
  String get settings => 'Settings';

  @override
  String get levels => 'Levels';

  @override
  String get gamePlaceholder => 'Game placeholder';

  @override
  String get backendUrlLabel => 'Backend URL';

  @override
  String get homeSubtitle => 'A graph puzzle foundation for the mobile game.';

  @override
  String get levelSelectionPlaceholder => 'Level selection placeholder';

  @override
  String get settingsPlaceholder => 'Settings placeholder';

  @override
  String get openGame => 'Open Game';
}
