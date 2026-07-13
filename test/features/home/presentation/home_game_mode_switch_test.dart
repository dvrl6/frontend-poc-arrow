import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/presentation/game_ui_keys.dart';
import 'package:frontend_poc_arrow/features/settings/domain/game_mode.dart';
import 'package:frontend_poc_arrow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kept in its own file on purpose: real rootBundle asset loads hang on the
// second navigation to the levels screen within one test process, so each
// test file gets at most one levels-screen visit (widget_test.dart already
// has one).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('should_switch_game_mode_from_home_screen', (tester) async {
    await tester.pumpWidget(const ArrowPocApp());
    await tester.pump();

    expect(find.byKey(GameUiKeys.gameModeSelector), findsOneWidget);

    // No pumpAndSettle here: the home background animation repeats forever,
    // so it never settles. Bounded pumps let the async save complete instead.
    await tester.tap(find.text('3D'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Persisted through the settings repository, not just flipped in memory.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.gameMode'), GameMode.threeD.storageKey);

    // The toggle itself must show the new selection (regression: the home
    // screen didn't listen to the settings controller, so the highlight
    // stayed on 2D even though the mode had changed underneath).
    expect(_segmentFillColor(tester, '3D'), isNot(Colors.transparent));
    expect(_segmentFillColor(tester, '2D'), Colors.transparent);

    // The reactive scope drives the level filter: opening Levels in 3D mode
    // shows internal level 21 (displayed as "Level 1" of the 3D set) and no
    // 2D cards.
    await tester.tap(find.text('Levels'));
    await _pumpUntilFound(tester, find.byKey(GameUiKeys.levelCard(21)));

    expect(find.byKey(GameUiKeys.levelCard(1)), findsNothing);
  });
}

/// Fill color of the mode segment holding [label] — the selected segment is
/// filled with its accent color, the unselected one is transparent.
Color? _segmentFillColor(WidgetTester tester, String label) {
  final container = tester.widget<AnimatedContainer>(
    find
        .ancestor(
          of: find.text(label),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
  return (container.decoration as BoxDecoration?)?.color;
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail(
    'Expected widget was not found: $finder. Exception: ${tester.takeException()}',
  );
}
