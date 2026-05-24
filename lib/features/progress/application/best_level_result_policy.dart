import '../domain/level_best_result.dart';

class BestLevelResultPolicy {
  const BestLevelResultPolicy();

  bool isBetter({
    required LevelBestResult candidate,
    required LevelBestResult? current,
  }) {
    if (current == null) {
      return true;
    }
    if (candidate.score != current.score) {
      return candidate.score > current.score;
    }
    if (candidate.moves != current.moves) {
      return candidate.moves < current.moves;
    }
    return candidate.timeSeconds < current.timeSeconds;
  }
}
