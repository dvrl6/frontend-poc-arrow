import '../domain/arrow_path.dart';
import '../domain/board_graph.dart';
import '../domain/game_session.dart';

/// Resolves a full sliding exit attempt for a single arrow.
///
/// Model: the arrow is a rigid piece — the head (`endNodeId`) leads; body nodes
/// follow the head's path. Only the head collides against other arrows.
/// The head sweeps forward by coordinate (`direction.applyTo(coordinate)` →
/// `nodeByCoordinate`) so blockers on sparse graphs (no connecting edge) are
/// still detected. Blocker hit or blocked edge → whole-arrow atomic rollback
/// (collision). Board boundary reached → exit.
///
/// The simulation is read-only — it never mutates the session. The moving
/// arrow's own covered nodes are never treated as blockers (no self-collision).
class MovementResolver {
  const MovementResolver();

  ExitAttemptOutcome resolve({
    required GameSession session,
    required ArrowPath arrow,
  }) {
    if (arrow.isEscaped) {
      return ExitAttemptOutcome.alreadyEscaped;
    }

    final graph = session.level.boardGraph;

    // Full occupied shape of every OTHER active arrow.
    final blockerNodes = <String>{};
    for (final other in session.activeArrows) {
      if (other.id == arrow.id) continue;
      blockerNodes.addAll(coveredNodeIds(graph, other));
    }

    // Sweep forward by coordinate from the HEAD only.
    // Body nodes follow the head's path — no independent collision check.
    final headNode = graph.nodeById(arrow.endNodeId);
    if (headNode != null) {
      var currentNode = headNode;
      while (true) {
        final nextCoord = arrow.direction.applyTo(currentNode.coordinate);
        final nextNode = graph.nodeByCoordinate(nextCoord);
        if (nextNode == null) break; // boundary → exit
        final edge = graph.getEdgeBetween(currentNode.id, nextNode.id);
        if (edge != null && edge.isBlocked) {
          return ExitAttemptOutcome.collision;
        }
        if (blockerNodes.contains(nextNode.id)) {
          return ExitAttemptOutcome.collision;
        }
        currentNode = nextNode;
      }
    }

    return ExitAttemptOutcome.escaped;
  }

  /// All graph node ids covered by [arrow]: its start node, end (head) node,
  /// and both endpoints of every occupied edge.
  static Set<String> coveredNodeIds(BoardGraph graph, ArrowPath arrow) {
    final ids = <String>{arrow.startNodeId, arrow.endNodeId};
    for (final edgeId in arrow.occupiedEdgeIds) {
      final edge = graph.edgeById(edgeId);
      if (edge != null) {
        ids.add(edge.fromNodeId);
        ids.add(edge.toNodeId);
      }
    }
    return ids;
  }
}

enum ExitAttemptOutcome {
  escaped,
  collision,
  alreadyEscaped,
}
