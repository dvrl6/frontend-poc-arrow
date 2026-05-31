import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/application/movement_resolver.dart';
import 'package:frontend_poc_arrow/features/game/domain/direction.dart';
import 'package:frontend_poc_arrow/features/game/domain/level_definition.dart';

import '../game_test_fixtures.dart';

void main() {
  const resolver = MovementResolver();

  // -------------------------------------------------------------------------
  // Escaped outcomes
  // -------------------------------------------------------------------------

  test('should_escape_when_head_is_at_board_boundary', () {
    // arrow head at c; no right-neighbor for c → exit.
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
    final arrow = session.arrowById('arrow-1')!;
    expect(resolver.resolve(session: session, arrow: arrow), ExitAttemptOutcome.escaped);
  });

  test('should_escape_single_segment_arrow_through_full_path', () {
    // arrow-1: head at b going right; path is b→c (free), then c exits.
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
        ],
      ),
    );
    final arrow = session.arrowById('arrow-1')!;
    // b→c is free, c has no right-neighbor → escaped.
    expect(resolver.resolve(session: session, arrow: arrow), ExitAttemptOutcome.escaped);
  });

  test('should_escape_multi_segment_arrow_sliding_to_boundary', () {
    // 2-segment arrow occupying ab+bc; head at c → exits right immediately.
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['ab', 'bc'],
            startNodeId: 'a',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );
    final arrow = session.arrowById('arrow-1')!;
    expect(resolver.resolve(session: session, arrow: arrow), ExitAttemptOutcome.escaped);
  });

  // -------------------------------------------------------------------------
  // Collision outcomes
  // -------------------------------------------------------------------------

  test('should_collide_when_another_arrow_occupies_path_ahead', () {
    // arrow-1 head at b going right; arrow-2 occupies bc → blocked.
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
    final arrow = session.arrowById('arrow-1')!;
    expect(resolver.resolve(session: session, arrow: arrow), ExitAttemptOutcome.collision);
  });

  test('should_collide_when_edge_is_blocked', () {
    // Default fixture arrow head at b going right; bc is blocked.
    final session = buildSession(basicDefinition(blockedEdgeIds: ['bc']));
    final arrow = session.arrowById('arrow-1')!;
    expect(resolver.resolve(session: session, arrow: arrow), ExitAttemptOutcome.collision);
  });

  test('should_not_self_collide_on_own_body_edges', () {
    // 2-segment arrow occupies ab+bc; head at c going right → exits (c is boundary).
    // The arrow's own edges must not be seen as blockers.
    final session = buildSession(
      basicDefinition(
        arrows: const [
          ArrowPathDefinition(
            id: 'arrow-1',
            occupiedEdgeIds: ['ab', 'bc'],
            startNodeId: 'a',
            endNodeId: 'c',
            direction: Direction.right,
          ),
        ],
      ),
    );
    final arrow = session.arrowById('arrow-1')!;
    expect(resolver.resolve(session: session, arrow: arrow), ExitAttemptOutcome.escaped);
  });

  test('should_collide_when_arrow_body_sweep_overlaps_another_arrow', () {
    // Full-shape collision: a horizontal arrow A (a-b-c on row 0) exits DOWN.
    // Its HEAD c sweeps to f (free), but its BODY node a sweeps to d, which is
    // occupied by arrow B. A head-only check would pass; the full-shape check
    // must report a collision.
    final session = buildSession(_grid3x2(
      arrows: const [
        ArrowPathDefinition(
          id: 'A',
          occupiedEdgeIds: ['a-b', 'b-c'],
          startNodeId: 'a',
          endNodeId: 'c',
          direction: Direction.down,
        ),
        ArrowPathDefinition(
          id: 'B',
          occupiedEdgeIds: ['d-e'],
          startNodeId: 'd',
          endNodeId: 'e',
          direction: Direction.right,
        ),
      ],
    ));

    final a = session.arrowById('A')!;
    expect(
      resolver.resolve(session: session, arrow: a),
      ExitAttemptOutcome.collision,
    );
  });

  test('should_escape_when_full_shape_sweep_is_clear', () {
    // Same board but B sits on row 0 far away; A exits down with all body rays
    // clear (no node below row 1).
    final session = buildSession(_grid3x2(
      arrows: const [
        ArrowPathDefinition(
          id: 'A',
          occupiedEdgeIds: ['d-e', 'e-f'],
          startNodeId: 'd',
          endNodeId: 'f',
          direction: Direction.down,
        ),
      ],
    ));

    final a = session.arrowById('A')!;
    // Row-1 nodes have no node beneath them → whole shape exits down.
    expect(
      resolver.resolve(session: session, arrow: a),
      ExitAttemptOutcome.escaped,
    );
  });

  // -------------------------------------------------------------------------
  // Guard — already escaped
  // -------------------------------------------------------------------------

  test('should_return_already_escaped_for_escaped_arrow', () {
    final session = buildSession(basicDefinition());
    final escaped = session.arrowById('arrow-1')!.copyWith(isEscaped: true);
    expect(resolver.resolve(session: session, arrow: escaped), ExitAttemptOutcome.alreadyEscaped);
  });
}

/// 3 columns x 2 rows grid:
///   a(0,0) b(1,0) c(2,0)
///   d(0,1) e(1,1) f(2,1)
LevelDefinition _grid3x2({required List<ArrowPathDefinition> arrows}) {
  return LevelDefinition(
    id: 'grid-3x2',
    name: 'Grid 3x2',
    nodes: const [
      GraphNodeDefinition(id: 'a', x: 0, y: 0),
      GraphNodeDefinition(id: 'b', x: 1, y: 0),
      GraphNodeDefinition(id: 'c', x: 2, y: 0),
      GraphNodeDefinition(id: 'd', x: 0, y: 1),
      GraphNodeDefinition(id: 'e', x: 1, y: 1),
      GraphNodeDefinition(id: 'f', x: 2, y: 1),
    ],
    edges: const [
      GraphEdgeDefinition(id: 'a-b', fromNodeId: 'a', toNodeId: 'b'),
      GraphEdgeDefinition(id: 'b-c', fromNodeId: 'b', toNodeId: 'c'),
      GraphEdgeDefinition(id: 'd-e', fromNodeId: 'd', toNodeId: 'e'),
      GraphEdgeDefinition(id: 'e-f', fromNodeId: 'e', toNodeId: 'f'),
      GraphEdgeDefinition(id: 'a-d', fromNodeId: 'a', toNodeId: 'd'),
      GraphEdgeDefinition(id: 'b-e', fromNodeId: 'b', toNodeId: 'e'),
      GraphEdgeDefinition(id: 'c-f', fromNodeId: 'c', toNodeId: 'f'),
    ],
    arrows: arrows,
    blockedEdgeIds: const [],
    metadata: const {'difficulty': 'test'},
  );
}
