import '../domain/player_settings.dart';

abstract interface class SettingsRepository {
  Future<PlayerSettings> getSettings();

  Future<void> saveSettings(PlayerSettings settings);
}
