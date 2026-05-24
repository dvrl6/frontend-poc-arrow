import 'level_best_result.dart';

class LocalProgress {
  const LocalProgress({
    required this.completedLevelNumbers,
    required this.bestResultsByLevel,
    required this.lastUnlockedLevel,
  });

  factory LocalProgress.initial() {
    return const LocalProgress(
      completedLevelNumbers: <int>{},
      bestResultsByLevel: <int, LevelBestResult>{},
      lastUnlockedLevel: 1,
    );
  }

  final Set<int> completedLevelNumbers;
  final Map<int, LevelBestResult> bestResultsByLevel;
  final int lastUnlockedLevel;

  bool isCompleted(int levelNumber) {
    return completedLevelNumbers.contains(levelNumber);
  }

  bool isUnlocked(int levelNumber) {
    return levelNumber <= lastUnlockedLevel || isCompleted(levelNumber);
  }

  LevelBestResult? bestResultFor(int levelNumber) {
    return bestResultsByLevel[levelNumber];
  }

  LocalProgress copyWith({
    Set<int>? completedLevelNumbers,
    Map<int, LevelBestResult>? bestResultsByLevel,
    int? lastUnlockedLevel,
  }) {
    return LocalProgress(
      completedLevelNumbers:
          completedLevelNumbers ?? this.completedLevelNumbers,
      bestResultsByLevel: bestResultsByLevel ?? this.bestResultsByLevel,
      lastUnlockedLevel: lastUnlockedLevel ?? this.lastUnlockedLevel,
    );
  }
}
