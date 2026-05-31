import '../domain/arrow_path.dart';
import '../domain/board_graph.dart';
import '../domain/game_session.dart';

/// Resolves a full sliding exit attempt for a single arrow, considering the
/// arrow's ENTIRE occupied shape — not only the head.
///
/// Model: the arrow is a rigid shape that translates one node-step at a time in
/// [ArrowPath.direction] until every covered node has left the board. For every
/// node the arrow currently covers, we walk the forward ray in the head
/// direction (using graph adjacency). If any forward node is occupied by another
/// active arrow (head, body, segment, or node), or any traversed edge is
/// blocked, the whole attempt is a collision. Otherwise the arrow escapes.
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

    // Sweep a forward ray from every node this arrow covers.
    final myNodes = coveredNodeIds(graph, arrow);
    for (final startNodeId in myNodes) {
      var current = startNodeId;
      while (true) {
        final edge = graph.getEdgeInDirection(current, arrow.direction);
        if (edge == null) {
          // This part of the shape reaches the board boundary → it exits.
          break;
        }
        if (edge.isBlocked) {
          return ExitAttemptOutcome.collision;
        }
        final neighbor = graph.getNeighbor(current, arrow.direction);
        if (neighbor == null) {
          break;
        }
        if (blockerNodes.contains(neighbor.id)) {
          return ExitAttemptOutcome.collision;
        }
        current = neighbor.id;
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
