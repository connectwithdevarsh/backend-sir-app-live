import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// AIBackgroundPainter renders a dynamic, subtle neural-network inspired background
/// with ambient glowing nodes, connecting grid lines, and soft light pulses.
class AIBackgroundPainter extends CustomPainter {
  final double animationValue;

  AIBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle ambient radial glow circles in corners
    final Paint glowPaintCyan = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryCyan.withValues(alpha: 0.12),
          AppTheme.primaryCyan.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.25),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.25),
      size.width * 0.6,
      glowPaintCyan,
    );

    final Paint glowPaintViolet = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.accentViolet.withValues(alpha: 0.10),
          AppTheme.accentViolet.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.7),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      size.width * 0.7,
      glowPaintViolet,
    );

    // 2. Draw subtle AI Grid Lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    const double gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Draw Animated Neural Nodes & Connection Lines
    final List<Offset> nodes = [
      Offset(size.width * 0.15, size.height * 0.20 + math.sin(animationValue * 2 * math.pi) * 6),
      Offset(size.width * 0.85, size.height * 0.18 + math.cos(animationValue * 2 * math.pi) * 8),
      Offset(size.width * 0.25, size.height * 0.50 + math.sin((animationValue + 0.3) * 2 * math.pi) * 5),
      Offset(size.width * 0.75, size.height * 0.55 + math.cos((animationValue + 0.5) * 2 * math.pi) * 7),
      Offset(size.width * 0.20, size.height * 0.80 + math.sin((animationValue + 0.7) * 2 * math.pi) * 6),
      Offset(size.width * 0.80, size.height * 0.82 + math.cos((animationValue + 0.2) * 2 * math.pi) * 5),
      Offset(size.width * 0.50, size.height * 0.12 + math.sin((animationValue + 0.4) * 2 * math.pi) * 8),
      Offset(size.width * 0.50, size.height * 0.88 + math.cos((animationValue + 0.6) * 2 * math.pi) * 6),
    ];

    // Connect close nodes with translucent cyan/violet lines
    final Paint linePaint = Paint()
      ..color = AppTheme.primaryCyan.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final double dist = (nodes[i] - nodes[j]).distance;
        if (dist < size.width * 0.55) {
          final double opacity = (1.0 - (dist / (size.width * 0.55))) * 0.15;
          linePaint.color = (i % 2 == 0 ? AppTheme.primaryCyan : AppTheme.secondaryTeal).withValues(alpha: opacity);
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // Draw node dots with glowing halos
    for (int i = 0; i < nodes.length; i++) {
      final Offset node = nodes[i];
      final double pulse = 2.0 + math.sin((animationValue * 2 * math.pi) + i) * 1.0;
      final Color nodeColor = i % 2 == 0 ? AppTheme.primaryCyan : AppTheme.accentViolet;

      // Outer soft glow
      final Paint nodeGlow = Paint()
        ..color = nodeColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(node, pulse + 3, nodeGlow);

      // Core dot
      final Paint nodeCore = Paint()..color = nodeColor.withValues(alpha: 0.8);
      canvas.drawCircle(node, pulse, nodeCore);
    }
  }

  @override
  bool shouldRepaint(covariant AIBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
