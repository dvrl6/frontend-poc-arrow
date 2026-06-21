import '../../settings/infrastructure/settings_dependencies.dart';
import '../application/background_music_controller.dart';
import '../application/game_audio_controller.dart';
import 'audio_players_audio_port.dart';
import 'audio_players_music_port.dart';

class AudioDependencies {
  const AudioDependencies._();

  static Future<GameAudioController> createGameAudioController() async {
    return GameAudioController(
      audioPort: AudioPlayersAudioPort(),
      getPlayerSettings:
          await SettingsDependencies.createGetPlayerSettingsUseCase(),
    );
  }

  static Future<BackgroundMusicController>
  createBackgroundMusicController() async {
    return BackgroundMusicController(
      musicPort: AudioPlayersMusicPort(),
      getPlayerSettings:
          await SettingsDependencies.createGetPlayerSettingsUseCase(),
    );
  }
}