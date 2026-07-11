import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/core/app/app_settings_controller.dart';
import 'package:frontend_poc_arrow/core/app/app_settings_scope.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';
import 'package:frontend_poc_arrow/core/theme/app_theme.dart';
import 'package:frontend_poc_arrow/features/game/domain/arrow_path.dart';
import 'package:frontend_poc_arrow/features/game/domain/board_coordinate.dart';
import 'package:frontend_poc_arrow/features/game/domain/board_graph.dart';
import 'package:frontend_poc_arrow/features/game/domain/direction.dart';
import 'package:frontend_poc_arrow/features/game/domain/graph_node.dart';
import 'package:frontend_poc_arrow/features/game/domain/level.dart';
import 'package:frontend_poc_arrow/features/game/presentation/game_screen.dart';
import 'package:frontend_poc_arrow/features/game/presentation/game_ui_keys.dart';
import 'package:frontend_poc_arrow/features/settings/domain/game_mode.dart';

void main() {
  testWidgets(
    'should_display_internal_2d_level_number_unchanged_in_app_bar',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(level: _singleNodeExitLevel(number: 5), gameMode: GameMode.twoD),
      );
      await tester.pump();

      expect(find.text('Level 5'), findsOneWidget);
    },
  );

  testWidgets(
    'should_map_internal_3d_level_21_to_displayed_level_1_in_app_bar',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          level: _singleNodeExitLevel(number: 21),
          gameMode: GameMode.threeD,
        ),
      );
      await tester.pump();

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Level 21'), findsNothing);
    },
  );

  testWidgets(
    'should_show_mapped_next_level_number_on_victory_in_3d_mode',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          level: _singleNodeExitLevel(number: 21),
          gameMode: GameMode.threeD,
        ),
      );
      await tester.pump();

      await tester.tapAt(
        tester.getTopLeft(find.byKey(GameUiKeys.gameBoard)) +
            const Offset(32, 32),
      );
      await tester.pump();

      expect(find.byKey(GameUiKeys.victoryCard), findsOneWidget);
      expect(find.byKey(GameUiKeys.nextLevelButton), findsOneWidget);
      // Internal level 22 (the next level after 21) displays as "2" in 3D
      // mode, not the internal number.
      expect(find.textContaining('Next level: 2'), findsOneWidget);
      expect(find.textContaining('Next level: 22'), findsNothing);
    },
  );
}

Level _singleNodeExitLevel({required int number}) {
  return Level(
    id: 'fixture-exit-$number',
    number: number,
    name: 'Level $number',
    boardGraph: BoardGraph(
      nodes: const [
        GraphNode(id: 'a', coordinate: BoardCoordinate(x: 0, y: 0)),
      ],
      edges: const [],
    ),
    arrows: const [
      ArrowPath(
        id: 'arrow-1',
        occupiedEdgeIds: [],
        orderedNodeIds: ['a'],
        startNodeId: 'a',
        endNodeId: 'a',
        direction: Direction.right,
      ),
    ],
    metadata: const {'difficulty': 'test'},
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.level, required this.gameMode});

  final Level level;
  final GameMode gameMode;

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: AppSettingsController(initialGameMode: gameMode),
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameScreen(
          levelNumber: level.number,
          enableBoardAnimations: false,
          loadLevelByNumber: (_) async => level,
          saveLevelCompletion:
              ({
                required int levelNumber,
                required int score,
                required int moves,
                required int timeSeconds,
              }) async {},
          getBestLevelResult: (_) async => null,
          notifyRemoteLevelCompletion:
              ({
                required int levelNumber,
                required int score,
                required int moves,
                required int timeSeconds,
              }) async {},
          playGameAudio: (_) async {},
        ),
      ),
    );
  }
}
