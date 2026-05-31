import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/application/move_arrow_command.dart';
import 'package:frontend_poc_arrow/features/game/application/move_arrow_use_case.dart';
import 'package:frontend_poc_arrow/features/game/application/movement_result.dart';
import 'package:frontend_poc_arrow/features/game/domain/direction.dart';
import 'package:frontend_poc_arrow/features/game/domain/game_status.dart';
import 'package:frontend_poc_arrow/features/game/domain/level_definition.dart';

import '../game_test_fixtures.dart';

void main() {
  const useCase = MoveArrowUseCase();

  // -------------------------------------------------------------------------
  // Exit attempt — success
  // -------------------------------------------------------------------------

  test('should_escape_arrow_when_path_to_boundary_is_clear', () {
    // arrow-1 starts at b→c (rightward). c has no right-neighbor → exits.
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );

    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );

    expect(result.outcome, MovementOutcome.escaped);
    expect(result.session.arrowById('arrow-1')?.isEscaped, isTrue);
    expect(result.session.movesCount, 1);
    expect(result.session.mistakeCount, 0);
  });

  test('should_set_victory_when_all_arrows_escape', () {
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );

    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );

    expect(result.session.status, GameStatus.victory);
  });

  test('should_keep_graph_nodes_visible_after_arrow_exits', () {
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );
    final nodeCountBefore = session.level.boardGraph.nodes.length;

    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );

    expect(result.session.level.boardGraph.nodes, hasLength(nodeCountBefore));
    expect(result.session.level.boardGraph.nodeById('c'), isNotNull);
  });

  // -------------------------------------------------------------------------
  // Exit attempt — collision (path blocked by another arrow)
  // -------------------------------------------------------------------------

  test('should_return_collision_when_path_is_blocked_by_another_arrow', () {
    // arrow-1 head is at b going right; arrow-2 occupies bc → blocked.
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['ab'],
            startNodeId: 'a',
            endNodeId: 'b',
            direction: Direction.right,
          ),
          ArrowPathDefinition(
            id: 'arrow-2',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );

    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );

    expect(result.outcome, MovementOutcome.collision);
    // Arrow position must not change (no partial movement).
    expect(result.session.arrowById('arrow-1')?.endNodeId, 'b');
    expect(result.session.arrowById('arrow-1')?.occupiedEdgeIds, ['ab']);
    expect(result.session.mistakeCount, 1);
    expect(result.session.movesCount, 1);
  });

  test('should_return_collision_when_path_is_blocked_by_a_blocked_edge', () {
    final session = buildSession(
      basicDefinition(blockedEdgeIds: ['bc']),
    );

    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );

    expect(result.outcome, MovementOutcome.collision);
    expect(result.session.arrowById('arrow-1')?.endNodeId, 'b');
    expect(result.session.mistakeCount, 1);
    expect(result.session.movesCount, 1);
  });

  // -------------------------------------------------------------------------
  // Rollback — no partial movement remains after collision
  // -------------------------------------------------------------------------

  test('should_leave_arrow_unchanged_after_collision', () {
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['ab'],
            startNodeId: 'a',
            endNodeId: 'b',
            direction: Direction.right,
          ),
          ArrowPathDefinition(
            id: 'arrow-2',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );
    final originalEdges =
        List<String>.from(session.arrowById('arrow-1')!.occupiedEdgeIds);

    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );

    expect(
      result.session.arrowById('arrow-1')!.occupiedEdgeIds,
      equals(originalEdges),
    );
  });

  // -------------------------------------------------------------------------
  // Lives system
  // -------------------------------------------------------------------------

  test('should_start_with_3_lives', () {
    final session = buildSession(basicDefinition());
    expect(session.livesRemaining, 3);
  });

  test('should_keep_3_lives_after_1_mistake', () {
    final session = buildSession(
      basicDefinition(blockedEdgeIds: ['bc']),
    );
    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(result.session.livesRemaining, 3);
    expect(result.session.mistakeCount, 1);
  });

  test('should_have_2_lives_after_2_mistakes', () {
    final session = buildSession(
      basicDefinition(blockedEdgeIds: ['bc']),
    );
    var s = session;
    for (var i = 0; i < 2; i++) {
      final result = useCase.execute(
        session: s,
        command: const MoveArrowCommand(arrowId: 'arrow-1'),
      );
      s = result.session;
    }
    expect(s.livesRemaining, 2);
    expect(s.mistakeCount, 2);
  });

  test('should_trigger_game_over_when_lives_reach_zero', () {
    // 6 collisions → 0 lives → GameStatus.failed.
    var session = buildSession(
      basicDefinition(blockedEdgeIds: ['bc']),
    );
    MovementResult result =
        MovementResult(session: session, outcome: MovementOutcome.collision);
    for (var i = 0; i < 6; i++) {
      result = useCase.execute(
        session: result.session,
        command: const MoveArrowCommand(arrowId: 'arrow-1'),
      );
    }
    expect(result.outcome, MovementOutcome.gameOver);
    expect(result.session.status, GameStatus.failed);
    expect(result.session.livesRemaining, 0);
  });

  // -------------------------------------------------------------------------
  // Guards
  // -------------------------------------------------------------------------

  test('should_return_already_escaped_when_arrow_is_already_escaped', () {
    // Two arrows: arrow-1 can exit right; arrow-2 is blocked so session
    // stays in playing state after arrow-1 escapes.
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
          // arrow-2 goes down from b; bd exists but no further down → exits
          // via the down direction. Use a direction with no neighbor to block
          // it: direction=left from a has no left neighbor → exits immediately.
          // To truly keep it active, use a direction where it collides.
          // Simplest: arrow-2 at ab going right is blocked by arrow-1 on bc.
          ArrowPathDefinition(
            id: 'arrow-2',
            occupiedEdgeIds: ['ab'],
            startNodeId: 'a',
            endNodeId: 'b',
            direction: Direction.right,
          ),
        ],
      ),
    );
    // Escape arrow-1 (path b→c→exit is clear; arrow-2 is on ab, not bc).
    final afterEscape = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(afterEscape.outcome, MovementOutcome.escaped);
    // Session is still playing because arrow-2 is active.
    expect(afterEscape.session.status, GameStatus.playing);

    // Tap the already-escaped arrow-1.
    final followUp = useCase.execute(
      session: afterEscape.session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(followUp.outcome, MovementOutcome.alreadyEscaped);
  });

  test('should_return_arrow_not_found_for_unknown_arrow_id', () {
    final session = buildSession(basicDefinition());
    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'nonexistent'),
    );
    expect(result.outcome, MovementOutcome.arrowNotFound);
  });

  test('should_return_session_not_active_when_session_is_failed', () {
    // Drive session to failed state first.
    var session = buildSession(
      basicDefinition(blockedEdgeIds: ['bc']),
    );
    MovementResult r =
        MovementResult(session: session, outcome: MovementOutcome.collision);
    for (var i = 0; i < 6; i++) {
      r = useCase.execute(
        session: r.session,
        command: const MoveArrowCommand(arrowId: 'arrow-1'),
      );
    }
    expect(r.session.status, GameStatus.failed);

    // Further input must be ignored.
    final after = useCase.execute(
      session: r.session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(after.outcome, MovementOutcome.sessionNotActive);
  });

  // -------------------------------------------------------------------------
  // Score formula
  // -------------------------------------------------------------------------

  test('should_calculate_score_correctly_with_no_mistakes', () {
    // 1 move, 0 mistakes → 1000 - 0 - 5 = 995
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['bc'],
            startNodeId: 'b',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );
    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(result.session.score.value, 995);
  });

  test('should_penalise_mistakes_heavily_in_score', () {
    // After 1 collision: moves=1, mistakes=1 → 1000 - 100 - 5 = 895
    final session = buildSession(
      basicDefinition(blockedEdgeIds: ['bc']),
    );
    final result = useCase.execute(
      session: session,
      command: const MoveArrowCommand(arrowId: 'arrow-1'),
    );
    expect(result.session.score.value, 895);
  });
}
