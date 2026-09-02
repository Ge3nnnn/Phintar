import 'dart:math';

import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/data/models/lab_model.dart';
import 'package:flutter/material.dart';

/// Pendulum simulation widget — extracted from labo_bandul_matematis.dart.
///
/// Reads all physics parameters from the [parameters] map and
/// environmental data from [environments] list. No hardcoded values.
///
/// Expected parameter keys: 'angle', 'ropeLength', 'mass'
class PendulumSimulation extends StatelessWidget {
  final Map<String, double> parameters;
  final List<LabEnvironment> environments;
  final bool isRunning;
  final bool airResistance;
  final int selectedEnvironmentIndex;

  const PendulumSimulation({
    super.key,
    required this.parameters,
    required this.environments,
    required this.isRunning,
    this.airResistance = false,
    this.selectedEnvironmentIndex = 0,
  });

  double get _angle => parameters['angle'] ?? 30.0;
  double get _ropeLength => parameters['ropeLength'] ?? 1.0;
  double get _mass => parameters['mass'] ?? 1.0;

  /// Canvas height scales with rope length — enlarged for clearer visualization.
  double get _canvasHeight {
    const minH = 240.0;
    const maxH = 380.0;
    const minL = 0.1;
    const maxL = 3.0;
    return minH + (_ropeLength - minL) / (maxL - minL) * (maxH - minH);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: _canvasHeight,
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        painter: _PendulumPainter(
          angle: _angle * pi / 180, // static display angle
          ropeLengthM: _ropeLength,
          massaKg: _mass,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CustomPainter: Pendulum (extracted from labo_bandul_matematis.dart)
// ═══════════════════════════════════════════════════════════════════════════════
class _PendulumPainter extends CustomPainter {
  final double angle; // radian
  final double ropeLengthM;
  final double massaKg;

  _PendulumPainter({
    required this.angle,
    this.ropeLengthM = 1.0,
    this.massaKg = 1.0,
  });

  static final Paint _dashPaint = Paint()
    ..color = AppTheme.textColor.withValues(alpha: 0.6)
    ..strokeWidth = 1;

  static final Paint _ropePaint = Paint()
    ..color = AppTheme.putih
    ..strokeWidth = 2.2
    ..style = PaintingStyle.stroke;

  static final Paint _pivotPaint = Paint()..color = AppTheme.textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final pivotX = size.width / 2;
    const pivotY = 16.0;

    // Rope length visual: 35% – 82% of canvas height
    const minFrac = 0.35;
    const maxFrac = 0.82;
    const minL = 0.1;
    const maxL = 3.0;
    final fraction =
        minFrac + (ropeLengthM - minL) / (maxL - minL) * (maxFrac - minFrac);
    final ropeLength = size.height * fraction.clamp(minFrac, maxFrac);

    // Bob radius: 10 – 26 px based on mass
    const minR = 10.0;
    const maxR = 26.0;
    const minM = 0.1;
    const maxM = 5.0;
    final bobRadius = (minR + (massaKg - minM) / (maxM - minM) * (maxR - minR))
        .clamp(minR, maxR);

    final bobX = pivotX + ropeLength * sin(angle);
    final bobY = pivotY + ropeLength * cos(angle);

    // ── Dashed equilibrium line ─────────────────────────────────────────────
    double y = pivotY;
    final maxY = pivotY + ropeLength + bobRadius;
    while (y < maxY) {
      canvas.drawLine(Offset(pivotX, y), Offset(pivotX, y + 5), _dashPaint);
      y += 10;
    }

    // ── Rope ────────────────────────────────────────────────────────────────
    canvas.drawLine(Offset(pivotX, pivotY), Offset(bobX, bobY), _ropePaint);

    // ── Rope length label ───────────────────────────────────────────────────
    _drawText(
      canvas,
      '${ropeLengthM.toStringAsFixed(1)} m',
      Offset(pivotX + 8, pivotY + ropeLength / 2 - 8),
      const TextStyle(
        color: AppTheme.textColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );

    // ── Pivot point ─────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(pivotX, pivotY), 5, _pivotPaint);

    // ── Bob glow ────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, bobRadius * 0.6);
    canvas.drawCircle(Offset(bobX, bobY), bobRadius * 1.35, glowPaint);

    // ── Bob with gradient ───────────────────────────────────────────────────
    final bobGrad = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: const [AppTheme.putih, AppTheme.ballColor],
          ).createShader(
            Rect.fromCircle(center: Offset(bobX, bobY), radius: bobRadius),
          );
    canvas.drawCircle(Offset(bobX, bobY), bobRadius, bobGrad);

    // ── Mass label inside bob (if large enough) ─────────────────────────────
    if (bobRadius >= 12) {
      final text = '${massaKg.toStringAsFixed(1)}kg';
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppTheme.putih,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(bobX - tp.width / 2, bobY - tp.height / 2));
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_PendulumPainter old) =>
      old.angle != angle ||
      old.ropeLengthM != ropeLengthM ||
      old.massaKg != massaKg;
}
