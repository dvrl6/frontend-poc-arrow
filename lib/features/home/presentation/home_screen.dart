// Game name: "Nodus" (Latin for "knot" / "node"). The core mechanic is
// untangling a graph of nodes and edges, so a word that literally means
// "knot" reads as on-theme without being generic ("Puzzle", "Arrow", "Game").
// Short, pronounceable across locales, and free of the placeholder "POC"
// branding this screen previously carried.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';

import '../../../core/config/app_config.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MenuBackgroundPainter(_backgroundController.value),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.neonMint, AppTheme.neonBlue],
                    ).createShader(bounds),
                    child: Text(
                      localizations.appTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.homeSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(flex: 4),
                  _MenuButton(
                    label: localizations.play,
                    accentColor: AppTheme.neonMint,
                    filled: true,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.levels),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: localizations.settings,
                    accentColor: AppTheme.neonPurple,
                    filled: false,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.settings),
                  ),
                  const Spacer(flex: 2),
                  _DebugRow(
                    label: localizations.backendUrlLabel,
                    value: AppConfig.apiBaseUrl,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.label,
    required this.accentColor,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final Color accentColor;
  final bool filled;
  final VoidCallback onPressed;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: widget.filled
                ? widget.accentColor
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: widget.filled
                ? null
                : Border.all(color: widget.accentColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(
                  alpha: _pressed ? 0.18 : 0.32,
                ),
                blurRadius: _pressed ? 8 : 18,
                spreadRadius: _pressed ? 0 : 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: widget.filled ? AppTheme.background : AppTheme.softText,
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppTheme.mutedText, fontSize: 11),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.mutedText, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight animated background: a handful of soft neon-tinted glows
/// drifting in slow circular orbits over the dark base color. Pure
/// [CustomPainter] geometry — no images, shaders, or physics — so it stays
/// cheap on low-end Android.
class _MenuBackgroundPainter extends CustomPainter {
  _MenuBackgroundPainter(this.t);

  final double t;

  static const _colors = [
    AppTheme.neonMint,
    AppTheme.neonBlue,
    AppTheme.neonPurple,
    AppTheme.neonPink,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppTheme.background,
    );

    final angle = t * 2 * math.pi;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.55;

    for (var i = 0; i < _colors.length; i++) {
      final orbitAngle = angle + (i * math.pi / 2);
      final orbitRadius = radius * (0.5 + 0.15 * i);
      final glowCenter = center +
          Offset(
            math.cos(orbitAngle) * orbitRadius,
            math.sin(orbitAngle) * orbitRadius * 0.6,
          );

      final paint = Paint()
        ..color = _colors[i].withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

      canvas.drawCircle(glowCenter, size.shortestSide * 0.35, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MenuBackgroundPainter oldDelegate) =>
      oldDelegate.t != t;
}
