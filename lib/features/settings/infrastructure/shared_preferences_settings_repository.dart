import 'package:shared_preferences/shared_preferences.dart';

import '../application/settings_repository.dart';
import '../domain/player_settings.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  const SharedPreferencesSettingsRepository(this._preferences);

  static const _soundEnabledKey = 'settings.soundEnabled';
  static const _musicEnabledKey = 'settings.musicEnabled';
  static const _languageCodeKey = 'settings.languageCode';

  final SharedPreferences _preferences;

  @override
  Future<PlayerSettings> getSettings() async {
    final defaults = PlayerSettings.defaults();
    return PlayerSettings(
      soundEnabled:
          _preferences.getBool(_soundEnabledKey) ?? defaults.soundEnabled,
      musicEnabled:
          _preferences.getBool(_musicEnabledKey) ?? defaults.musicEnabled,
      languageCode: _preferences.getString(_languageCodeKey),
    );
  }

  @override
  Future<void> saveSettings(PlayerSettings settings) async {
    await _preferences.setBool(_soundEnabledKey, settings.soundEnabled);
    await _preferences.setBool(_musicEnabledKey, settings.musicEnabled);
    final languageCode = settings.languageCode;
    if (languageCode == null) {
      await _preferences.remove(_languageCodeKey);
    } else {
      await _preferences.setString(_languageCodeKey, languageCode);
    }
  }
}
