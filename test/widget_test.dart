import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/main.dart';

void main() {
  testWidgets('should_show_home_screen_when_app_starts', (tester) async {
    await tester.pumpWidget(const ArrowPocApp());
    await tester.pumpAndSettle();

    expect(find.text('Arrow POC'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('http://10.0.2.2:3000'), findsOneWidget);
  });

  testWidgets('should_open_level_selection_when_play_is_tapped', (tester) async {
    await tester.pumpWidget(const ArrowPocApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.text('Level selection placeholder'), findsOneWidget);
    expect(find.text('Open Game'), findsOneWidget);
  });
}
