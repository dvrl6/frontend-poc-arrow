import '../../settings/infrastructure/settings_dependencies.dart';
import '../application/game_audio_controller.dart';
import 'system_sound_audio_port.dart';

class AudioDependencies {
  const AudioDependencies._();

  static Future<GameAudioController> createGameAudioController() async {
    return GameAudioController(
      audioPort: const SystemSoundAudioPort(),
      getPlayerSettings:
          await SettingsDependencies.createGetPlayerSettingsUseCase(),
    );
  }
}
