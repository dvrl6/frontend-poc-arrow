import 'game_mode.dart';

class PlayerSettings {
  const PlayerSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    this.languageCode,
    this.gameMode = GameMode.twoD,
  });

  factory PlayerSettings.defaults() {
    return const PlayerSettings(soundEnabled: true, musicEnabled: true);
  }

  final bool soundEnabled;
  final bool musicEnabled;
  final String? languageCode;
  final GameMode gameMode;

  PlayerSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    String? languageCode,
    bool clearLanguage = false,
    GameMode? gameMode,
  }) {
    return PlayerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      languageCode: clearLanguage ? null : languageCode ?? this.languageCode,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}
