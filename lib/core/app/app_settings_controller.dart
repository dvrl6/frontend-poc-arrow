import 'package:flutter/widgets.dart';

/// App-level state for cross-cutting UI preferences (currently the active
/// locale; theme can be added here later without touching screens).
class AppSettingsController extends ChangeNotifier {
  AppSettingsController({Locale? initialLocale}) : _locale = initialLocale;

  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    if (locale == _locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }
}