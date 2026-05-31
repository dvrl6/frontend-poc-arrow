import '../domain/game_session.dart';

enum MovementOutcome {
  /// Arrow successfully slid out of the board.
  escaped,

  /// Exit attempt was blocked by another arrow or a blocked edge.
  /// The arrow stays at its original position (no partial movement).
  collision,

  /// Exit attempt failed and lives reached zero — session is now failed.
  gameOver,

  /// The tapped arrow id does not exist in this session.
  arrowNotFound,

  /// The tapped arrow has already escaped.
  alreadyEscaped,

  /// The session is not in the playing state; input is ignored.
  sessionNotActive,
}

class MovementResult {
  const MovementResult({
    required this.session,
    required this.outcome,
  });

  final GameSession session;
  final MovementOutcome outcome;
}
