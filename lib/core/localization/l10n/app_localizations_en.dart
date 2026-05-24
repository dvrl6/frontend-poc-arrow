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

  @override
  String get moves => 'Moves';

  @override
  String get score => 'Score';

  @override
  String get victory => 'Victory';

  @override
  String get retry => 'Retry';

  @override
  String get nextLevel => 'Next level';

  @override
  String get backToLevels => 'Back to levels';

  @override
  String get levelNotFound => 'Level not found';

  @override
  String get loadingLevel => 'Loading level';

  @override
  String get locked => 'Locked';

  @override
  String get completed => 'Completed';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get bestScore => 'Best score';

  @override
  String get levelLocked => 'Complete previous levels to unlock this level.';

  @override
  String get soundEnabled => 'Sound effects';

  @override
  String get musicEnabled => 'Music';

  @override
  String get soundFoundationDescription =>
      'Lightweight tap feedback is used while final sound assets are pending.';

  @override
  String get musicFutureDescription =>
      'Music is a future enhancement because no music assets are included yet.';

  @override
  String get language => 'Language';

  @override
  String get languageDisplayValue => 'English';

  @override
  String get resetProgress => 'Reset local progress';

  @override
  String get resetProgressConfirmation =>
      'This clears completed levels, best scores, and unlocked progress. Settings stay unchanged.';

  @override
  String get progressReset => 'Local progress reset.';

  @override
  String get cancel => 'Cancel';

  @override
  String get loadingSettings => 'Loading settings';
}
