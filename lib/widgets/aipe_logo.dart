import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// AipeLogo represents the official icon for AIPE LAB.
/// It combines AI neural nodes, circuit geometry, and the prompt engineering cursor `>_`.
class AipeLogo extends StatelessWidget {
  final double size;
  final bool animateGlow;

  const AipeLogo({
    super.key,
    this.size = 100.0,
    this.animateGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          // Soft cyan glow behind the logo
          BoxShadow(
            color: AppTheme.primaryCyan.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          // Accent violet secondary glow
          BoxShadow(
            color: AppTheme.accentViolet.withValues(alpha: 0.20),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          width: 2.0,
          color: AppTheme.primaryCyan.withValues(alpha: 0.6),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.26),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Circuit Grid Lines inside icon
            CustomPaint(
              size: Size(size, size),
              painter: LogoCircuitPainter(),
            ),

            // Inner Central Emblem (Prompt symbol >_ & Neural Spark)
            Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryCyan.withValues(alpha: 0.2),
                    AppTheme.accentViolet.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Prompt Cursor symbol '>_'
                    Text(
                      '>_',
                      style: GoogleFonts.firaCode(
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryCyan,
                        shadows: [
                          Shadow(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Academic Golden Sparkle Indicator
            Positioned(
              top: size * 0.12,
              right: size * 0.14,
              child: Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.academicGold,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.academicGold,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: size * 0.08,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LogoCircuitPainter draws abstract AI circuit lines inside the logo badge.
class LogoCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppTheme.primaryCyan.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Paint nodePaint = Paint()
      ..color = AppTheme.primaryCyan
      ..style = PaintingStyle.fill;

    // Corner circuits
    final Path path1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.15);
    canvas.drawPath(path1, linePaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.3), 2.5, nodePaint);

    final Path path2 = Path()
      ..moveTo(size.width * 0.85, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.85);
    canvas.drawPath(path2, linePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), 2.5, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
