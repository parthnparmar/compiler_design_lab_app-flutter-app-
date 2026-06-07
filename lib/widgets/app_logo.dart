import 'dart:math';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({super.key, this.size = 100, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: showShadow
            ? [BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 20, offset: const Offset(0, 6))]
            : null,
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
        size: Size(size, size),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final pad = size.width * 0.12;

    // ── Gradient background inside rounded square ─────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.25),
    );
    canvas.drawRRect(rrect, bgPaint);

    // ── Gear ─────────────────────────────────────────────────────────────
    final gearRadius    = size.width * 0.30;
    final holeRadius    = size.width * 0.14;
    final toothOuter    = size.width * 0.37;
    final toothInner    = gearRadius;
    const teethCount    = 8;
    const toothHalfAngle = 0.18; // radians

    final gearPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final gearPath = Path();
    for (int i = 0; i < teethCount; i++) {
      final baseAngle = (2 * pi / teethCount) * i - pi / 2;
      // outer tooth points
      final a1 = baseAngle - toothHalfAngle;
      final a2 = baseAngle + toothHalfAngle;
      // inner (valley) points
      final a0 = baseAngle - toothHalfAngle - (pi / teethCount) + toothHalfAngle;
      final a3 = baseAngle + toothHalfAngle + (pi / teethCount) - toothHalfAngle;

      if (i == 0) {
        gearPath.moveTo(cx + toothInner * cos(a0 - 0.22), cy + toothInner * sin(a0 - 0.22));
      }
      gearPath.lineTo(cx + toothInner * cos(a1 - 0.10), cy + toothInner * sin(a1 - 0.10));
      gearPath.lineTo(cx + toothOuter * cos(a1),         cy + toothOuter * sin(a1));
      gearPath.lineTo(cx + toothOuter * cos(a2),         cy + toothOuter * sin(a2));
      gearPath.lineTo(cx + toothInner * cos(a2 + 0.10), cy + toothInner * sin(a2 + 0.10));
    }
    gearPath.close();
    canvas.drawPath(gearPath, gearPaint);

    // gear hole (punch out)
    final holePaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), holeRadius, holePaint);

    // ── "CD" text in center hole ──────────────────────────────────────────
    final tp = TextPainter(
      text: TextSpan(
        text: 'CD',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    // ── Bottom tagline bar ────────────────────────────────────────────────
    final barPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.fill;
    final barRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, size.height * 0.76, size.width - pad * 2, size.height * 0.14),
      const Radius.circular(6),
    );
    canvas.drawRRect(barRRect, barPaint);

    final tp2 = TextPainter(
      text: TextSpan(
        text: 'COMPILER LAB',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.095,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas,
        Offset(cx - tp2.width / 2, size.height * 0.76 + (size.height * 0.14 - tp2.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
