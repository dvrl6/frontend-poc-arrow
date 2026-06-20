import 'package:flutter/material.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
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

  /// Pan/zoom transform for dense boards. Reset via the reset-view button.
  final TransformationController _viewController = TransformationController();

  @override
  void initState() {
    super.initState();
    _activeIds = widget.session.activeArrows.map((a) => a.id).toSet();
    if (widget.animate) {
      _exitController =
          AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
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
    _viewController.dispose();
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

            final board = GestureDetector(
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

            // Pan/zoom for dense boards. The tap GestureDetector lives inside
            // the transformed child, so hit testing stays in child coordinates.
            return Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _viewController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(24),
                    child: board,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _ResetViewButton(onPressed: _resetView),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _resetView() {
    _viewController.value = Matrix4.identity();
  }
}

class _ResetViewButton extends StatelessWidget {
  const _ResetViewButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Tooltip(
      message: localizations.resetView,
      child: Material(
        color: AppTheme.surface.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          key: GameUiKeys.resetViewButton,
          icon: const Icon(Icons.center_focus_strong, size: 20),
          tooltip: localizations.resetView,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
