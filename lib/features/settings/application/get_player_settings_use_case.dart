import '../domain/player_settings.dart';
import 'settings_repository.dart';

class GetPlayerSettingsUseCase {
  const GetPlayerSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<PlayerSettings> call() {
    return _repository.getSettings();
  }
}
