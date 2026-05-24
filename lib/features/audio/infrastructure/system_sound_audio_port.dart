import 'package:flutter/services.dart';

import '../application/audio_port.dart';
import '../application/game_audio_event.dart';

class SystemSoundAudioPort implements AudioPort {
  const SystemSoundAudioPort();

  @override
  Future<void> play(GameAudioEvent event) {
    return SystemSound.play(SystemSoundType.click);
  }
}
