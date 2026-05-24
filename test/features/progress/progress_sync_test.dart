import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/progress/application/merge_progress_use_case.dart';
import 'package:frontend_poc_arrow/features/progress/domain/level_best_result.dart';
import 'package:frontend_poc_arrow/features/progress/domain/local_progress.dart';
import 'package:frontend_poc_arrow/features/progress/domain/remote_progress_entry.dart';

void main() {
  test('should_keep_local_progress_when_remote_progress_is_stale', () {
    final merge = const MergeProgressUseCase();
    final local = LocalProgress.initial().copyWith(
      completedLevelNumbers: {1},
      bestResultsByLevel: const {
        1: LevelBestResult(score: 990, moves: 1, timeSeconds: 0),
      },
      lastUnlockedLevel: 2,
    );

    final merged = merge(
      local: local,
      remoteEntries: const [
        RemoteProgressEntry(
          levelId: 'remote-level-1',
          completed: true,
          bestScore: 900,
          bestMoves: 5,
          bestTimeSeconds: 0,
        ),
      ],
      levelIdsByNumber: const {1: 'remote-level-1'},
    );

    expect(merged.bestResultFor(1)?.score, 990);
    expect(merged.bestResultFor(1)?.moves, 1);
  });

  test('should_merge_remote_progress_when_remote_is_better', () {
    final merge = const MergeProgressUseCase();
    final local = LocalProgress.initial().copyWith(
      bestResultsByLevel: const {
        2: LevelBestResult(score: 800, moves: 7, timeSeconds: 0),
      },
    );

    final merged = merge(
      local: local,
      remoteEntries: const [
        RemoteProgressEntry(
          levelId: 'remote-level-2',
          completed: true,
          bestScore: 950,
          bestMoves: 2,
          bestTimeSeconds: 0,
        ),
      ],
      levelIdsByNumber: const {2: 'remote-level-2'},
    );

    expect(merged.isCompleted(2), isTrue);
    expect(merged.isUnlocked(3), isTrue);
    expect(merged.bestResultFor(2)?.score, 950);
  });
}
