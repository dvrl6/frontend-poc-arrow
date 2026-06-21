import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../application/music_port.dart';

class AudioPlayersMusicPort implements MusicPort {
  AudioPlayersMusicPort() : _player = AudioPlayer();

  final AudioPlayer _player;
  static const String _asset = 'audio/background_music.mp3';
  static const double _musicVolume = 1.1;

  @override
  Future<void> start() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_musicVolume);
      await _player.play(AssetSource(_asset));
    } catch (error) {
      debugPrint('AudioPlayersMusicPort.start failed: $error');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('AudioPlayersMusicPort.stop failed: $error');
    }
  }

  Future<void> dispose() => _player.dispose();
}