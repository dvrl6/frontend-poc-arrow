import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/core/app/app_settings_controller.dart';
import 'package:frontend_poc_arrow/core/app/app_settings_scope.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';
import 'package:frontend_poc_arrow/core/theme/app_theme.dart';
import 'package:frontend_poc_arrow/features/game/domain/board_coordinate.dart';
import 'package:frontend_poc_arrow/features/game/domain/board_graph.dart';
import 'package:frontend_poc_arrow/features/game/domain/graph_node.dart';
import 'package:frontend_poc_arrow/features/game/domain/level.dart';
import 'package:frontend_poc_arrow/features/game/presentation/game_ui_keys.dart';
import 'package:frontend_poc_arrow/features/levels/presentation/level_selection_screen.dart';
import 'package:frontend_poc_arrow/features/progress/domain/local_progress.dart';
import 'package:frontend_poc_arrow/features/settings/domain/game_mode.dart';

void main() {
  testWidgets(
    'in_3d_mode_with_empty_progress_first_3d_card_unlocked_rest_locked',
    (tester) async {
      final levels = List<Level>.generate(
        5,
        (index) => _threeDLevel(number: 21 + index),
      );

      await tester.pumpWidget(
        _TestApp(
          levels: levels,
          progress: LocalProgress.initial(),
          gameMode: GameMode.threeD,
        ),
      );
      await tester.pumpAndSettle();

      // The first 3D card (internal 21) is unlocked → chevron, tappable.
      expect(
        find.descendant(
          of: find.byKey(GameUiKeys.levelCard(21)),
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
        findsOneWidget,
      );

      // The remaining four 3D cards (internal 22-25) are locked.
      for (final number in const [22, 23, 24, 25]) {
        expect(
          find.descendant(
            of: find.byKey(GameUiKeys.levelCard(number)),
            matching: find.byIcon(Icons.lock_rounded),
          ),
          findsOneWidget,
          reason: 'internal level $number should be locked',
        );
      }
    },
  );
}

Level _threeDLevel({required int number}) {
  return Level(
    id: 'fixture-3d-$number',
    number: number,
    name: 'Level $number',
    boardGraph: BoardGraph(
      nodes: const [
        GraphNode(id: 'a', coordinate: BoardCoordinate(x: 0, y: 0, z: 0)),
        GraphNode(id: 'b', coordinate: BoardCoordinate(x: 0, y: 0, z: 1)),
      ],
      edges: const [],
    ),
    arrows: const [],
    metadata: const {'difficulty': 'test'},
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.levels,
    required this.progress,
    required this.gameMode,
  });

  final List<Level> levels;
  final LocalProgress progress;
  final GameMode gameMode;

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: AppSettingsController(initialGameMode: gameMode),
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LevelSelectionScreen(
          loadLevels: () async => levels,
          loadProgress: () async => progress,
        ),
      ),
    );
  }
}
