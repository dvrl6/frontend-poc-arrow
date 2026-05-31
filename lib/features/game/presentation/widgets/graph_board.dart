import 'package:flutter/material.dart';

import '../game_ui_keys.dart';
import '../../domain/arrow_path.dart';
import '../../domain/game_session.dart';
import 'graph_board_hit_tester.dart';
import 'graph_board_layout.dart';
import 'graph_board_painter.dart';

/// Renders the graph board and animates already-resolved attempts.
///
/// Game rules live in domain/application. This widget only *renders* the result:
/// when an arrow has just become escaped it plays a slide-out animation of the
/// whole arrow shape in its head direction; when an arrow has just collided it
/// plays a short shake + the collision flash colour. No rule logic here.
class GraphBoard extends StatefulWidget {
  const GraphBoard({
    required this.session,
    required this.onArrowActivated,
    this.lastActivatedArrowId,
    this.flashingArrowId,
    this.animate = true,
    super.key,
  });

  final GameSession session;
  final ValueChanged<String> onArrowActivated;
  final String? lastActivatedArrowId;

  /// Arrow drawn in the collision-error colour for the flash duration.
  final String? flashingArrowId;

  /// When false (tests), no tickers/animations are started; the final resolved
  /// state is rendered immediately.
  final bool animate;

  @override
  State<GraphBoard> createState() => _GraphBoardState();
}

class _GraphBoardState extends State<GraphBoard>
    with TickerProviderStateMixin {
  AnimationController? _exitController;
  AnimationController? _shakeController;
  ArrowPath? _exitingArrow;
  Set<String> _activeIds = const {};
  String? _shakeArrowId;

  @override
  void initState() {
    super.initState();
    _activeIds = widget.session.activeArrows.map((a) => a.id).toSet();
    if (widget.animate) {
      _exitController =
          AnimationController(vsync: this, duration: const Duration(milliseconds: 360))
            ..addListener(() => setState(() {}))
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                setState(() => _exitingArrow = null);
              }
            });
      _shakeController =
          AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
            ..addListener(() => setState(() {}))
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                setState(() => _shakeArrowId = null);
              }
            });
    }
  }

  @override
  void didUpdateWidget(covariant GraphBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _activeIds = widget.session.activeArrows.map((a) => a.id).toSet();
      return;
    }

    final newActive = widget.session.activeArrows.map((a) => a.id).toSet();

    // An arrow that just transitioned from active -> escaped: animate its exit.
    final escapedNow = _activeIds.difference(newActive);
    if (escapedNow.isNotEmpty) {
      final id = escapedNow.first;
      final arrow = widget.session.arrowById(id);
      if (arrow != null) {
        _exitingArrow = arrow;
        _exitController?.forward(from: 0);
      }
    }
    _activeIds = newActive;

    // A new collision flash target: play a short shake.
    if (widget.flashingArrowId != null &&
        widget.flashingArrowId != oldWidget.flashingArrowId) {
      _shakeArrowId = widget.flashingArrowId;
      _shakeController?.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _exitController?.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeArrowCount = widget.session.activeArrows.length;

    return Semantics(
      label:
          'Graph board with ${widget.session.level.boardGraph.nodes.length} nodes and $activeArrowCount active arrows',
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final layout = GraphBoardLayout.fromGraph(
              graph: widget.session.level.boardGraph,
              size: size,
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final arrowId = const GraphBoardHitTester().findArrowAt(
                  session: widget.session,
                  layout: layout,
                  position: details.localPosition,
                );
                if (arrowId != null) {
                  widget.onArrowActivated(arrowId);
                }
              },
              child: CustomPaint(
                key: GameUiKeys.gameBoard,
                painter: GraphBoardPainter(
                  session: widget.session,
                  lastActivatedArrowId: widget.lastActivatedArrowId,
                  flashingArrowId: widget.flashingArrowId,
                  exitingArrow: _exitingArrow,
                  exitProgress: _exitController?.value ?? 0,
                  shakeArrowId: _shakeArrowId,
                  shakeProgress: _shakeController?.value ?? 0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
