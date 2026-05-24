import '../domain/level_best_result.dart';
import 'local_progress_repository.dart';
import 'merge_progress_use_case.dart';
import 'remote_level_repository.dart';
import 'remote_progress_repository.dart';

class SyncProgressUseCase {
  const SyncProgressUseCase({
    required LocalProgressRepository localProgressRepository,
    required RemoteProgressRepository remoteProgressRepository,
    required RemoteLevelRepository remoteLevelRepository,
    this.mergeProgress = const MergeProgressUseCase(),
  }) : _localProgressRepository = localProgressRepository,
       _remoteProgressRepository = remoteProgressRepository,
       _remoteLevelRepository = remoteLevelRepository;

  final LocalProgressRepository _localProgressRepository;
  final RemoteProgressRepository _remoteProgressRepository;
  final RemoteLevelRepository _remoteLevelRepository;
  final MergeProgressUseCase mergeProgress;

  Future<void> call() async {
    final local = await _localProgressRepository.getProgress();
    final levelIdsByNumber = await _remoteLevelRepository.getLevelIdsByNumber();
    final remote = await _remoteProgressRepository.getMyProgress();
    final merged = mergeProgress(
      local: local,
      remoteEntries: remote,
      levelIdsByNumber: levelIdsByNumber,
    );
    await _localProgressRepository.saveProgress(merged);

    for (final levelNumber in merged.completedLevelNumbers) {
      final levelId = levelIdsByNumber[levelNumber];
      if (levelId == null) {
        continue;
      }
      final best = merged.bestResultFor(levelNumber);
      await _remoteProgressRepository.syncProgress(
        levelId: levelId,
        completed: true,
        bestScore: best?.score,
        bestMoves: best?.moves,
        bestTimeSeconds: best?.timeSeconds,
      );
    }

    for (final entry in merged.bestResultsByLevel.entries) {
      if (merged.completedLevelNumbers.contains(entry.key)) {
        continue;
      }
      await _syncBestOnly(entry.key, entry.value, levelIdsByNumber);
    }
  }

  Future<void> _syncBestOnly(
    int levelNumber,
    LevelBestResult best,
    Map<int, String> levelIdsByNumber,
  ) async {
    final levelId = levelIdsByNumber[levelNumber];
    if (levelId == null) {
      return;
    }
    await _remoteProgressRepository.syncProgress(
      levelId: levelId,
      completed: false,
      bestScore: best.score,
      bestMoves: best.moves,
      bestTimeSeconds: best.timeSeconds,
    );
  }
}
