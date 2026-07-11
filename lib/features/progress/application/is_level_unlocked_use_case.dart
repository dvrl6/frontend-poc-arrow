import '../../settings/domain/game_mode.dart';
import 'local_progress_repository.dart';

/// Legacy use case: as of Phase 24.2 the level-selection gate computes unlock
/// directly via `isLevelUnlockedForMode` / [LocalProgress.isUnlockedForMode],
/// so this has **zero production callers**. Kept for test coverage of the
/// mode-aware rule at the application layer; do not delete. It now delegates to
/// the same authoritative domain rule.
class IsLevelUnlockedUseCase {
  const IsLevelUnlockedUseCase(this._repository);

  final LocalProgressRepository _repository;

  Future<bool> call(int levelNumber, GameMode mode) async {
    final progress = await _repository.getProgress();
    return progress.isUnlockedForMode(levelNumber, mode);
  }
}
