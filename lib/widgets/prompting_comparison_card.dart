import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompting_result.dart';
import '../theme/app_theme.dart';

/// PromptingComparisonCard provides a 3-way comparative matrix across
/// Zero-Shot, Few-Shot, and Role-Based prompting techniques.
class PromptingComparisonCard extends StatelessWidget {
  final List<PromptingResult> results;
  final Map<String, String> evaluationRatings; // criteriaKey -> "Zero-Shot", "Few-Shot", "Role-Based", "Similar"
  final Function(String criteriaKey, String rating) onRatingChanged;

  const PromptingComparisonCard({
    super.key,
    required this.results,
    required this.evaluationRatings,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final criteria = [
      {'key': 'relevance', 'label': '1. Relevance to Task'},
      {'key': 'clarity', 'label': '2. Clarity of Explanation'},
      {'key': 'specificity', 'label': '3. Specificity & Depth'},
      {'key': 'structure', 'label': '4. Output Formatting & Structure'},
      {'key': 'instruction', 'label': '5. Instruction Following'},
      {'key': 'consistency', 'label': '6. Output Pattern Consistency'},
      {'key': 'suitability', 'label': '7. Educational Suitability'},
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
                  '3-WAY TECHNIQUE COMPARISON',
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

          // 3-Way Summary Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: results.map((res) {
              Color techColor;
              String label;
              if (res.method == 'few_shot') {
                techColor = AppTheme.secondaryTeal;
                label = 'FEW-SHOT';
              } else if (res.method == 'role_based') {
                techColor = AppTheme.accentPurple;
                label = 'ROLE-BASED';
              } else {
                techColor = AppTheme.primaryCyan;
                label = 'ZERO-SHOT';
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: techColor.withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.firaCode(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: techColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${res.executionTimeMs} ms',
                          style: GoogleFonts.firaCode(fontSize: 10, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          res.output,
                          style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Criteria Header
          Text(
            'STUDENT OBSERVATION MATRIX',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select which technique performed best across each empirical evaluation criterion:',
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
            final currentSelected = evaluationRatings[key] ?? 'Role-Based';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildChoiceChip(key, 'Zero-Shot', currentSelected == 'Zero-Shot', AppTheme.primaryCyan),
                        const SizedBox(width: 4),
                        _buildChoiceChip(key, 'Few-Shot', currentSelected == 'Few-Shot', AppTheme.secondaryTeal),
                        const SizedBox(width: 4),
                        _buildChoiceChip(key, 'Role-Based', currentSelected == 'Role-Based', AppTheme.accentPurple),
                        const SizedBox(width: 4),
                        _buildChoiceChip(key, 'Similar', currentSelected == 'Similar', const Color(0xFFF59E0B)),
                      ],
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

  Widget _buildChoiceChip(String key, String title, bool isSelected, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () => onRatingChanged(key, title),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
