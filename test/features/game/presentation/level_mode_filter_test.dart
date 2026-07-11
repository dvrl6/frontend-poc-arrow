import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/presentation/level_mode_filter.dart';
import 'package:frontend_poc_arrow/features/progress/domain/local_progress.dart';
import 'package:frontend_poc_arrow/features/settings/domain/game_mode.dart';

LocalProgress _progressWith(Set<int> completed) {
  return LocalProgress.initial().copyWith(completedLevelNumbers: completed);
}

void main() {
  group('firstInternalLevelFor', () {
    test('returns 1 for 2D and 21 for 3D', () {
      expect(firstInternalLevelFor(GameMode.twoD), 1);
      expect(firstInternalLevelFor(GameMode.threeD), 21);
    });
  });

  group('isLevelUnlockedForMode', () {
    test('3D first level (internal 21) is unlocked with empty progress', () {
      final progress = _progressWith(const <int>{});
      expect(isLevelUnlockedForMode(progress, 21, GameMode.threeD), isTrue);
    });

    test('3D internal 22 locked until 21 completed, unlocked after', () {
      expect(
        isLevelUnlockedForMode(_progressWith(const <int>{}), 22, GameMode.threeD),
        isFalse,
      );
      expect(
        isLevelUnlockedForMode(
          _progressWith(const <int>{21}),
          22,
          GameMode.threeD,
        ),
        isTrue,
      );
    });

    test('completing 2D level 20 does not unlock 3D internal 21', () {
      final progress = _progressWith(const <int>{20});
      // 21 is unlocked anyway because it is the first 3D level, but not *because
      // of* level 20 — 22 must stay locked.
      expect(isLevelUnlockedForMode(progress, 22, GameMode.threeD), isFalse);
    });

    test('completing 3D internal 21 does not unlock 2D level 2', () {
      final progress = _progressWith(const <int>{21});
      expect(isLevelUnlockedForMode(progress, 2, GameMode.twoD), isFalse);
    });

    test('2D level 1 unlocked by default; level 2 locked until 1 completed', () {
      expect(
        isLevelUnlockedForMode(_progressWith(const <int>{}), 1, GameMode.twoD),
        isTrue,
      );
      expect(
        isLevelUnlockedForMode(_progressWith(const <int>{}), 2, GameMode.twoD),
        isFalse,
      );
      expect(
        isLevelUnlockedForMode(_progressWith(const <int>{1}), 2, GameMode.twoD),
        isTrue,
      );
    });
  });
}
