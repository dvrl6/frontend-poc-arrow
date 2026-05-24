import 'package:flutter/foundation.dart';

import '../../progress/application/reset_local_progress_use_case.dart';
import '../application/get_player_settings_use_case.dart';
import '../application/save_player_settings_use_case.dart';
import '../domain/player_settings.dart';

enum SettingsScreenLoadState { loading, ready, failed }

class SettingsScreenController extends ChangeNotifier {
  SettingsScreenController({
    required GetPlayerSettingsUseCase getPlayerSettings,
    required SavePlayerSettingsUseCase savePlayerSettings,
    required ResetLocalProgressUseCase resetLocalProgress,
  }) : _getPlayerSettings = getPlayerSettings,
       _savePlayerSettings = savePlayerSettings,
       _resetLocalProgress = resetLocalProgress;

  final GetPlayerSettingsUseCase _getPlayerSettings;
  final SavePlayerSettingsUseCase _savePlayerSettings;
  final ResetLocalProgressUseCase _resetLocalProgress;

  SettingsScreenLoadState _loadState = SettingsScreenLoadState.loading;
  PlayerSettings _settings = PlayerSettings.defaults();

  SettingsScreenLoadState get loadState => _loadState;
  PlayerSettings get settings => _settings;

  Future<void> load() async {
    _loadState = SettingsScreenLoadState.loading;
    notifyListeners();

    try {
      _settings = await _getPlayerSettings();
      _loadState = SettingsScreenLoadState.ready;
      notifyListeners();
    } catch (_) {
      _loadState = SettingsScreenLoadState.failed;
      notifyListeners();
    }
  }

  Future<void> setSoundEnabled(bool value) async {
    await _save(_settings.copyWith(soundEnabled: value));
  }

  Future<void> setMusicEnabled(bool value) async {
    await _save(_settings.copyWith(musicEnabled: value));
  }

  Future<void> resetProgress() {
    return _resetLocalProgress();
  }

  Future<void> _save(PlayerSettings updatedSettings) async {
    _settings = updatedSettings;
    notifyListeners();
    await _savePlayerSettings(updatedSettings);
  }
}
