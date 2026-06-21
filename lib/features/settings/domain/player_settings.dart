class PlayerSettings {
  const PlayerSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    this.languageCode,
  });

  factory PlayerSettings.defaults() {
    return const PlayerSettings(soundEnabled: true, musicEnabled: true);
  }

  final bool soundEnabled;
  final bool musicEnabled;
  final String? languageCode;

  PlayerSettings copyWith({bool? soundEnabled, bool? musicEnabled, String? languageCode, bool clearLanguage = false}) {
    return PlayerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      languageCode: clearLanguage ? null : languageCode ?? this.languageCode,
    );
  }
}
