import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../application/audio_port.dart';
import '../application/game_audio_event.dart';

/// Real sound-effects adapter backed by the `audioplayers` package.
/// Each [GameAudioEvent] maps to a short asset under `assets/audio/`.
class AudioPlayersAudioPort implements AudioPort {
  AudioPlayersAudioPort() : _player = AudioPlayer();

  final AudioPlayer _player;
  static const double _effectsVolume = 0.25;
  static final AudioContext _audioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.notification,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  static const Map<GameAudioEvent, String> _assetByEvent = {
    GameAudioEvent.move: 'audio/move.mp3',
    GameAudioEvent.blocked: 'audio/blocked.mp3',
    GameAudioEvent.victory: 'audio/victory.mp3',
    GameAudioEvent.defeat: 'audio/defeat.mp3',
  };

  @override
  Future<void> play(GameAudioEvent event) async {
    final asset = _assetByEvent[event];
    if (asset == null) {
      return;
    }
    try {
      await _player.setAudioContext(_audioContext);
      await _player.setVolume(_effectsVolume);
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (error) {
      debugPrint('AudioPlayersAudioPort failed for $event: $error');
    }
  }

  Future<void> dispose() => _player.dispose();
}