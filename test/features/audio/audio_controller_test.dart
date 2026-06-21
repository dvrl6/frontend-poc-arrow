import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/audio/application/audio_port.dart';
import 'package:frontend_poc_arrow/features/audio/application/game_audio_controller.dart';
import 'package:frontend_poc_arrow/features/audio/application/game_audio_event.dart';
import 'package:frontend_poc_arrow/features/settings/application/get_player_settings_use_case.dart';
import 'package:frontend_poc_arrow/features/settings/application/settings_repository.dart';
import 'package:frontend_poc_arrow/features/settings/domain/player_settings.dart';

void main() {
  test('should_play_audio_feedback_when_sound_is_enabled', () async {
    final audioPort = _FakeAudioPort();
    final controller = GameAudioController(
      audioPort: audioPort,
      getPlayerSettings: GetPlayerSettingsUseCase(
        _FakeSettingsRepository(
          const PlayerSettings(soundEnabled: true, musicEnabled: false),
        ),
      ),
    );

    await controller.play(GameAudioEvent.move);

    expect(audioPort.playedEvents, [GameAudioEvent.move]);
  });

  test('should_not_play_audio_feedback_when_sound_is_disabled', () async {
    final audioPort = _FakeAudioPort();
    final controller = GameAudioController(
      audioPort: audioPort,
      getPlayerSettings: GetPlayerSettingsUseCase(
        _FakeSettingsRepository(
          const PlayerSettings(soundEnabled: false, musicEnabled: false),
        ),
      ),
    );

    await controller.play(GameAudioEvent.move);

    expect(audioPort.playedEvents, isEmpty);
  });

  test('should_play_defeat_event_when_sound_is_enabled', () async {
    final audioPort = _FakeAudioPort();
    final controller = GameAudioController(
      audioPort: audioPort,
      getPlayerSettings: GetPlayerSettingsUseCase(
        _FakeSettingsRepository(
          const PlayerSettings(soundEnabled: true, musicEnabled: false),
        ),
      ),
    );

    await controller.play(GameAudioEvent.defeat);

    expect(audioPort.playedEvents, [GameAudioEvent.defeat]);
  });

  test('should_not_play_defeat_event_when_sound_is_disabled', () async {
    final audioPort = _FakeAudioPort();
    final controller = GameAudioController(
      audioPort: audioPort,
      getPlayerSettings: GetPlayerSettingsUseCase(
        _FakeSettingsRepository(
          const PlayerSettings(soundEnabled: false, musicEnabled: false),
        ),
      ),
    );

    await controller.play(GameAudioEvent.defeat);

    expect(audioPort.playedEvents, isEmpty);
  });
}

class _FakeAudioPort implements AudioPort {
  final playedEvents = <GameAudioEvent>[];

  @override
  Future<void> play(GameAudioEvent event) async {
    playedEvents.add(event);
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  final PlayerSettings _settings;

  @override
  Future<PlayerSettings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(PlayerSettings settings) async {}
}
