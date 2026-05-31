import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/application/movement_result.dart';
import 'package:frontend_poc_arrow/features/game/domain/direction.dart';
import 'package:frontend_poc_arrow/features/game/domain/level_definition.dart';
import 'package:frontend_poc_arrow/features/game/presentation/game_screen_controller.dart';

import '../game_test_fixtures.dart';

void main() {
  test('should_record_escape_trace_when_arrow_exits', () async {
    final controller = GameScreenController(
      levelNumber: 1,
      loadLevelByNumber: (_) async => buildLevel(
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
      ),
    );
    await controller.load();

    controller.activateArrow('arrow-1');

    expect(controller.lastAttemptTrace?.arrowId, 'arrow-1');
    expect(controller.lastAttemptTrace?.outcome, MovementOutcome.escaped);
    controller.dispose();
  });

  test('should_record_collision_trace_and_flash_when_blocked', () async {
    final controller = GameScreenController(
      levelNumber: 1,
      loadLevelByNumber: (_) async => buildLevel(
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
      ),
    );
    await controller.load();

    controller.activateArrow('arrow-1');

    expect(controller.lastAttemptTrace?.arrowId, 'arrow-1');
    expect(controller.lastAttemptTrace?.outcome, MovementOutcome.collision);
    // Flash target is set synchronously for the collision feedback.
    expect(controller.flashingArrowId, 'arrow-1');
    expect(controller.mistakeCount, 1);
    controller.dispose();
  });

  test('should_reset_trace_lives_and_mistakes_on_restart', () async {
    final controller = GameScreenController(
      levelNumber: 1,
      loadLevelByNumber: (_) async => buildLevel(
        basicDefinition(blockedEdgeIds: ['bc']),
      ),
    );
    await controller.load();

    controller.activateArrow('arrow-1'); // collision → 1 mistake, trace set
    expect(controller.mistakeCount, 1);
    expect(controller.lastAttemptTrace, isNotNull);

    controller.restart();

    expect(controller.mistakeCount, 0);
    expect(controller.livesRemaining, 3);
    expect(controller.lastAttemptTrace, isNull);
    controller.dispose();
  });
}
