import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/study_result.dart';
import '../theme/app_theme.dart';

/// AiResultCard displays AI explanations or study summaries for Practical 12.
class AiResultCard extends StatelessWidget {
  final StudyResult result;

  const AiResultCard({
    super.key,
    required this.result,
  });

  void _copyResult(BuildContext context) {
    Clipboard.setData(ClipboardData(text: result.result));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.secondaryTeal, size: 16),
            const SizedBox(width: 8),
            Text('Result copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isExplain = result.taskType == 'explain';
    final title = isExplain ? 'AI CONCEPT EXPLANATION' : 'AI STUDY SUMMARY';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.secondaryTeal, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Model: ${result.model} • ${result.executionTimeMs}ms',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _copyResult(context),
                icon: const Icon(Icons.copy, size: 12),
                label: Text(
                  isExplain ? '📋 COPY EXPLANATION' : '📋 COPY SUMMARY',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Output Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: SelectableText(
              result.result.trim(),
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFFE2E8F0),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
