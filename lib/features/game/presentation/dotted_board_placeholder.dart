import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class DottedBoardPlaceholder extends StatelessWidget {
  const DottedBoardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.neonMint.withValues(alpha: 0.2)),
        ),
        child: const CustomPaint(
          painter: _DottedBoardPlaceholderPainter(),
        ),
      ),
    );
  }
}

class _DottedBoardPlaceholderPainter extends CustomPainter {
  const _DottedBoardPlaceholderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppTheme.neonMint.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final guidePaint = Paint()
      ..color = AppTheme.neonMint.withValues(alpha: 0.12)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()
      ..color = AppTheme.pastelAmber.withValues(alpha: 0.85)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    const gridSize = 5;
    final spacing = size.width / (gridSize + 1);
    final points = <Offset>[];

    for (var y = 1; y <= gridSize; y++) {
      for (var x = 1; x <= gridSize; x++) {
        points.add(Offset(x * spacing, y * spacing));
      }
    }

    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize - 1; x++) {
        final start = points[y * gridSize + x];
        final end = points[y * gridSize + x + 1];
        canvas.drawLine(start, end, guidePaint);
      }
    }

    for (var x = 0; x < gridSize; x++) {
      for (var y = 0; y < gridSize - 1; y++) {
        final start = points[y * gridSize + x];
        final end = points[(y + 1) * gridSize + x];
        canvas.drawLine(start, end, guidePaint);
      }
    }

    final pathPoints = [
      points[15],
      points[16],
      points[17],
      points[12],
    ];
    for (var i = 0; i < pathPoints.length - 1; i++) {
      canvas.drawLine(pathPoints[i], pathPoints[i + 1], accentPaint);
    }

    for (final point in points) {
      canvas.drawCircle(point, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
