import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/application/move_arrow_command.dart';
import 'package:frontend_poc_arrow/features/game/application/move_arrow_use_case.dart';
import 'package:frontend_poc_arrow/features/game/application/movement_result.dart';
import 'package:frontend_poc_arrow/features/game/domain/game_session.dart';
import 'package:frontend_poc_arrow/features/game/domain/game_status.dart';

import '../game_test_fixtures.dart';

void main() {
  const useCase = MoveArrowUseCase();

  GameSession startBlockedSession() {
    return buildSession(basicDefinition(blockedEdgeIds: ['bc']));
  }

  MovementResult collide(GameSession session) {
    return useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
  }

  // -------------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------------

  test('should_start_with_3_lives_and_0_mistakes', () {
    final session = buildSession(basicDefinition());
    expect(session.livesRemaining, 3);
    expect(session.mistakeCount, 0);
  });

  // -------------------------------------------------------------------------
  // Lives formula: 3 - (mistakes ~/ 2)
  // -------------------------------------------------------------------------

  test('should_keep_3_lives_after_1_mistake', () {
    var s = startBlockedSession();
    s = collide(s).session;
    expect(s.mistakeCount, 1);
    expect(s.livesRemaining, 3);
  });

  test('should_have_2_lives_after_2_mistakes', () {
    var s = startBlockedSession();
    s = collide(collide(s).session).session;
    expect(s.mistakeCount, 2);
    expect(s.livesRemaining, 2);
  });

  test('should_keep_2_lives_after_3_mistakes', () {
    var s = startBlockedSession();
    for (var i = 0; i < 3; i++) {
      s = collide(s).session;
    }
    expect(s.mistakeCount, 3);
    expect(s.livesRemaining, 2);
  });

  test('should_have_1_life_after_4_mistakes', () {
    var s = startBlockedSession();
    for (var i = 0; i < 4; i++) {
      s = collide(s).session;
    }
    expect(s.mistakeCount, 4);
    expect(s.livesRemaining, 1);
  });

  test('should_keep_1_life_after_5_mistakes', () {
    var s = startBlockedSession();
    for (var i = 0; i < 5; i++) {
      s = collide(s).session;
    }
    expect(s.mistakeCount, 5);
    expect(s.livesRemaining, 1);
  });

  test('should_trigger_game_over_when_mistakes_reach_6', () {
    var s = startBlockedSession();
    MovementResult r = MovementResult(session: s, outcome: MovementOutcome.collision);
    for (var i = 0; i < 6; i++) {
      r = collide(r.session);
    }
    expect(r.outcome, MovementOutcome.gameOver);
    expect(r.session.status, GameStatus.failed);
    expect(r.session.livesRemaining, 0);
  });

  // -------------------------------------------------------------------------
  // Session guard after failure
  // -------------------------------------------------------------------------

  test('should_ignore_input_when_session_is_failed', () {
    var s = startBlockedSession();
    MovementResult r = MovementResult(session: s, outcome: MovementOutcome.collision);
    for (var i = 0; i < 6; i++) {
      r = collide(r.session);
    }
    // Session is now failed; further taps must return sessionNotActive.
    final after = useCase.execute(
      session: r.session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(after.outcome, MovementOutcome.sessionNotActive);
    // Counts must not change.
    expect(after.session.mistakeCount, r.session.mistakeCount);
    expect(after.session.movesCount, r.session.movesCount);
  });

  // -------------------------------------------------------------------------
  // Restart resets lives
  // -------------------------------------------------------------------------

  test('should_reset_lives_and_mistakes_on_restart', () {
    final level = buildSession(basicDefinition()).level;
    var s = buildSession(basicDefinition(blockedEdgeIds: ['bc']));
    for (var i = 0; i < 4; i++) {
      s = collide(s).session;
    }
    expect(s.mistakeCount, 4);
    expect(s.livesRemaining, 1);

    // Simulate restart — create fresh session from same level.
    final fresh = GameSession.start(level);
    expect(fresh.mistakeCount, 0);
    expect(fresh.livesRemaining, 3);
  });
}
