import '../../settings/application/get_player_settings_use_case.dart';
import 'audio_port.dart';
import 'game_audio_event.dart';

class GameAudioController {
  const GameAudioController({
    required AudioPort audioPort,
    required GetPlayerSettingsUseCase getPlayerSettings,
  }) : _audioPort = audioPort,
       _getPlayerSettings = getPlayerSettings;

  final AudioPort _audioPort;
  final GetPlayerSettingsUseCase _getPlayerSettings;

  Future<void> play(GameAudioEvent event) async {
    final settings = await _getPlayerSettings();
    if (!settings.soundEnabled) {
      return;
    }

    await _audioPort.play(event);
  }
}
