import '../domain/player_settings.dart';
import 'settings_repository.dart';

class SavePlayerSettingsUseCase {
  const SavePlayerSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(PlayerSettings settings) {
    return _repository.saveSettings(settings);
  }
}
