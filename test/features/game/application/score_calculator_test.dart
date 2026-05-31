import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/application/score_calculator.dart';

void main() {
  const calculator = ScoreCalculator();

  test('should_give_max_score_with_no_moves_and_no_mistakes', () {
    final score = calculator.calculate(
      movesCount: 0,
      mistakeCount: 0,
      elapsedSeconds: 0,
    );
    expect(score.value, 1000);
  });

  test('should_deduct_5_per_attempt', () {
    // 4 attempts, 0 mistakes → 1000 - 0 - 20 = 980
    final score = calculator.calculate(
      movesCount: 4,
      mistakeCount: 0,
      elapsedSeconds: 0,
    );
    expect(score.value, 980);
  });

  test('should_deduct_100_per_mistake', () {
    // 2 mistakes, 2 moves → 1000 - 200 - 10 = 790
    final score = calculator.calculate(
      movesCount: 2,
      mistakeCount: 2,
      elapsedSeconds: 0,
    );
    expect(score.value, 790);
  });

  test('should_not_go_below_zero', () {
    final score = calculator.calculate(
      movesCount: 100,
      mistakeCount: 20,
      elapsedSeconds: 0,
    );
    expect(score.value, 0);
  });

  test('should_not_penalise_elapsed_seconds_in_new_formula', () {
    // elapsedSeconds is accepted but not used in the new formula.
    final a = calculator.calculate(
      movesCount: 2,
      mistakeCount: 1,
      elapsedSeconds: 0,
    );
    final b = calculator.calculate(
      movesCount: 2,
      mistakeCount: 1,
      elapsedSeconds: 999,
    );
    expect(a.value, b.value);
  });
}
