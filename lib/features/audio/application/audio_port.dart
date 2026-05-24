import 'game_audio_event.dart';

abstract interface class AudioPort {
  Future<void> play(GameAudioEvent event);
}
