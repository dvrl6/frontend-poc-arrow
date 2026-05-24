class PlayerSettings {
  const PlayerSettings({
    required this.soundEnabled,
    required this.musicEnabled,
  });

  factory PlayerSettings.defaults() {
    return const PlayerSettings(soundEnabled: true, musicEnabled: false);
  }

  final bool soundEnabled;
  final bool musicEnabled;

  PlayerSettings copyWith({bool? soundEnabled, bool? musicEnabled}) {
    return PlayerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
    );
  }
}
