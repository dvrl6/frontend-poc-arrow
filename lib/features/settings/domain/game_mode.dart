/// Which level set the main menu targets: 2D (levels 1-20) or 3D (21-25).
/// [storageKey] is the stable value persisted via [PlayerSettings]/
/// SharedPreferences; it is decoupled from any localized UI label.
enum GameMode {
  twoD('2D'),
  threeD('3D');

  const GameMode(this.storageKey);

  final String storageKey;

  static GameMode fromStorageKey(String? key) {
    return GameMode.values.firstWhere(
      (mode) => mode.storageKey == key,
      orElse: () => GameMode.twoD,
    );
  }
}
