import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// RagProcessingIndicator renders document processing stages in real-time.
class RagProcessingIndicator extends StatelessWidget {
  final int currentStep; // 1 to 5

  const RagProcessingIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Extracting text...',
      'Creating chunks...',
      'Creating embeddings...',
      'Building index...',
      'Ready for questions ✓',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'DOCUMENT INDEXING PIPELINE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children: steps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final label = entry.value;
              final isDone = idx < currentStep;
              final isCurrent = idx == currentStep;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : (isCurrent ? Icons.play_arrow_rounded : Icons.radio_button_unchecked_rounded),
                      size: 16,
                      color: isDone
                          ? AppTheme.secondaryTeal
                          : (isCurrent ? AppTheme.primaryCyan : AppTheme.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'STEP $idx: $label',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.5,
                        fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
                        color: isDone
                            ? AppTheme.secondaryTeal
                            : (isCurrent ? Colors.white : AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
