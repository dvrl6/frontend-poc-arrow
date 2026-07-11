import 'package:flutter/widgets.dart';

import '../../features/settings/domain/game_mode.dart';

/// App-level state for cross-cutting UI preferences (currently the active
/// locale and game mode; theme can be added here later without touching
/// screens).
class AppSettingsController extends ChangeNotifier {
  AppSettingsController({Locale? initialLocale, GameMode? initialGameMode})
    : _locale = initialLocale,
      _gameMode = initialGameMode ?? GameMode.twoD;

  Locale? _locale;
  GameMode _gameMode;

  Locale? get locale => _locale;
  GameMode get gameMode => _gameMode;

  void setLocale(Locale? locale) {
    if (locale == _locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }

  void setGameMode(GameMode mode) {
    if (mode == _gameMode) {
      return;
    }
    _gameMode = mode;
    notifyListeners();
  }
}