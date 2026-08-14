import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// BeforeAfterCodeCard displays a side-by-side comparison of the original code
/// vs the AI-generated corrected code with a developer review disclaimer.
class BeforeAfterCodeCard extends StatelessWidget {
  final String originalCode;
  final String correctedCode;

  const BeforeAfterCodeCard({
    super.key,
    required this.originalCode,
    required this.correctedCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_rounded, color: AppTheme.accentPurple, size: 18),
              const SizedBox(width: 8),
              Text(
                'BEFORE vs AFTER CODE COMPARISON',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Side by side cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Before Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEFORE (ORIGINAL)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        originalCode.trim(),
                        style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // After Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AFTER (AI CORRECTED)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTeal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        correctedCode.trim(),
                        style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Educational Disclaimer Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated fix. Always review and test code in your development environment before production use.',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
