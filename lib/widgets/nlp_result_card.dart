import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/nlp_result.dart';
import '../theme/app_theme.dart';

/// NlpResultCard displays the real AI classification/sentiment result,
/// dynamic AI explanation, execution duration, and real model metadata.
class NlpResultCard extends StatelessWidget {
  final NlpResult result;
  final String inputText;
  final VoidCallback onCopy;

  const NlpResultCard({
    super.key,
    required this.result,
    required this.inputText,
    required this.onCopy,
  });

  Color _getLabelColor(String label) {
    switch (label.toUpperCase()) {
      case 'POSITIVE':
        return const Color(0xFF10B981); // Emerald Green
      case 'NEGATIVE':
        return const Color(0xFFEF4444); // Crimson Red
      case 'NEUTRAL':
        return AppTheme.academicGold; // Amber Gold
      default:
        return AppTheme.primaryCyan; // Electric Cyan for Categories
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label.toUpperCase()) {
      case 'POSITIVE':
        return Icons.sentiment_very_satisfied_rounded;
      case 'NEGATIVE':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'NEUTRAL':
        return Icons.sentiment_neutral_rounded;
      default:
        return Icons.label_important_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _getLabelColor(result.label);
    final labelIcon = _getLabelIcon(result.label);
    final String modelLabel = (result.model != null && result.model!.isNotEmpty)
        ? 'Model: ${result.model}'
        : 'REAL AI RESPONSE';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: labelColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: labelColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: NLP RESULT & COPY BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_rounded, size: 18, color: labelColor),
                  const SizedBox(width: 8),
                  Text(
                    'REAL AI NLP RESULT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onCopy,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(Icons.copy_rounded, size: 14, color: labelColor),
                label: Text(
                  'COPY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),

          // PRIMARY PREDICTION BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: labelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: labelColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: labelColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(labelIcon, size: 28, color: labelColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.task == 'sentiment'
                            ? 'PREDICTED SENTIMENT'
                            : 'PREDICTED CLASSIFICATION',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: labelColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // REAL CONFIDENCE SCORE (ONLY RENDERED IF BACKEND PROVIDES REAL VALUE)
          if (result.confidence != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MODEL CONFIDENCE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${(result.confidence! * 100).toInt()}% (${result.confidence})',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: result.confidence,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(labelColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // REAL AI EXPLANATION & DYNAMIC ANALYSIS OUTPUT
          if (result.explanation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI ANALYSIS & REASONING',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.explanation,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // METADATA BADGES (STATUS, ACTUAL LATENCY, REAL MODEL)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetaPill(
                icon: Icons.check_circle_rounded,
                label: 'Status: 200 OK',
                color: const Color(0xFF10B981),
              ),
              _buildMetaPill(
                icon: Icons.timer_rounded,
                label: 'Latency: ${result.executionTimeMs} ms',
                color: AppTheme.academicGold,
              ),
              _buildMetaPill(
                icon: Icons.memory_rounded,
                label: modelLabel,
                color: AppTheme.primaryCyan,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
