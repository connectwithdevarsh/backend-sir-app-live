import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_execution_result.dart';
import '../theme/app_theme.dart';

/// ComparisonCard provides a comparative side-by-side or stacked view
/// of the Before and After outputs along with a student evaluation criteria matrix.
class ComparisonCard extends StatelessWidget {
  final PromptExecutionResult beforeResult;
  final PromptExecutionResult afterResult;
  final Map<String, String> evaluationRatings; // criteriaKey -> "Better", "Similar", "Needs Improvement"
  final Function(String criteriaKey, String rating) onRatingChanged;

  const ComparisonCard({
    super.key,
    required this.beforeResult,
    required this.afterResult,
    required this.evaluationRatings,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final criteria = [
      {'key': 'relevance', 'label': 'Relevance to Task'},
      {'key': 'clarity', 'label': 'Clarity of Content'},
      {'key': 'structure', 'label': 'Formatting & Structure'},
      {'key': 'instruction', 'label': 'Instruction Following'},
      {'key': 'specificity', 'label': 'Specificity & Detail'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: AppTheme.primaryCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'BEFORE VS AFTER COMPARISON',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'EVALUATION',
                  style: GoogleFonts.firaCode(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Side-by-Side Prompts Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Before Summary Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 14, color: AppTheme.secondaryTeal),
                          const SizedBox(width: 6),
                          Text(
                            'BEFORE REFINEMENT',
                            style: GoogleFonts.firaCode(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Prompt:',
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.textMuted),
                      ),
                      Text(
                        beforeResult.prompt,
                        style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Latency: ${beforeResult.executionTimeMs} ms',
                        style: GoogleFonts.firaCode(fontSize: 10, color: AppTheme.secondaryTeal),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // After Summary Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.accentPurple),
                          const SizedBox(width: 6),
                          Text(
                            'AFTER REFINEMENT',
                            style: GoogleFonts.firaCode(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Prompt:',
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.textMuted),
                      ),
                      Text(
                        afterResult.prompt,
                        style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Latency: ${afterResult.executionTimeMs} ms',
                        style: GoogleFonts.firaCode(fontSize: 10, color: AppTheme.accentPurple),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Comparison Criteria Matrix Header
          Text(
            'STUDENT COMPARATIVE EVALUATION MATRIX',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record your empirical evaluation across the 5 core Prompt Engineering dimensions:',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),

          const SizedBox(height: 12),

          // Criteria Rows
          ...criteria.map((c) {
            final key = c['key']!;
            final label = c['label']!;
            final currentRating = evaluationRatings[key] ?? 'Better';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildRatingChip(key, 'Better', currentRating == 'Better', const Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          _buildRatingChip(key, 'Similar', currentRating == 'Similar', const Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          _buildRatingChip(key, 'Needs Imp.', currentRating == 'Needs Imp.', const Color(0xFFEF4444)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRatingChip(String key, String rating, bool isSelected, Color color) {
    return InkWell(
      onTap: () => onRatingChanged(key, rating),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
          ),
        ),
        child: Text(
          rating,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}
