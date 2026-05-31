import '../domain/score.dart';

abstract interface class ScoreStrategy {
  Score calculate({
    required int movesCount,
    required int mistakeCount,
    required int elapsedSeconds,
  });
}

/// score = max(0, 1000 − (mistakeCount × 100) − (movesCount × 5))
///
/// Mistakes (failed exit attempts) are penalised heavily because each one
/// risks a life. Total attempts are penalised lightly to reward efficiency.
class DefaultScoreStrategy implements ScoreStrategy {
  const DefaultScoreStrategy();

  @override
  Score calculate({
    required int movesCount,
    required int mistakeCount,
    required int elapsedSeconds,
  }) {
    final value = 1000 - (mistakeCount * 100) - (movesCount * 5);
    return Score(value < 0 ? 0 : value);
  }
}
