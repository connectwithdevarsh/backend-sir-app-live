import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// EvaluationCard provides interactive evaluation controls for the student
/// to evaluate accuracy, reasoning, and ambiguity handling without fake auto-labels.
class EvaluationCard extends StatelessWidget {
  final String category; // "factual", "logical", "ambiguous"
  final String? selectedAccuracy; // "Correct", "Incorrect", "Uncertain", "Possible Hallucination", "Not Enough Information"
  final ValueChanged<String> onAccuracySelected;
  final List<String> selectedAmbiguityChecks;
  final ValueChanged<String> onAmbiguityCheckToggled;

  const EvaluationCard({
    super.key,
    required this.category,
    required this.selectedAccuracy,
    required this.onAccuracySelected,
    required this.selectedAmbiguityChecks,
    required this.onAmbiguityCheckToggled,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> accuracyOptions = [
      {
        'label': 'CORRECT',
        'key': 'Correct',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'INCORRECT',
        'key': 'Incorrect',
        'icon': Icons.cancel_outlined,
        'color': const Color(0xFFEF4444),
      },
      {
        'label': 'UNCERTAIN',
        'key': 'Uncertain',
        'icon': Icons.help_outline_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'POSSIBLE HALLUCINATION',
        'key': 'Possible Hallucination',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'label': 'NOT ENOUGH INFORMATION',
        'key': 'Not Enough Information',
        'icon': Icons.info_outline_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    final bool isAmbiguous = category.toLowerCase() == 'ambiguous';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.35),
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
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppTheme.accentPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'EVALUATE RESPONSE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                'STUDENT EVALUATION',
                style: GoogleFonts.firaCode(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Based on your analysis and reference comparison, classify the model\'s response:',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),

          const SizedBox(height: 14),

          // Accuracy / Observation Option Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accuracyOptions.map((opt) {
              final bool isSelected = selectedAccuracy == opt['key'];
              final Color color = opt['color'] as Color;

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 14,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      opt['label'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: color.withValues(alpha: 0.35),
                backgroundColor: const Color(0xFF0F172A),
                side: BorderSide(
                  color: isSelected ? color : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
                onSelected: (_) => onAccuracySelected(opt['key'] as String),
              );
            }).toList(),
          ),

          // Ambiguity Specific Evaluation Section
          if (isAmbiguous) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.help_center_outlined,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AMBIGUITY HANDLING OBSERVATION',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Expected Behavior: The model should recognize insufficient context and ask for clarification rather than confidently assuming one interpretation.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ambiguity Checkboxes / Toggle Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAmbiguityCheckChip(
                        label: 'Asked for clarification',
                        checkKey: 'clarification',
                        icon: Icons.check_circle_outline,
                        activeColor: const Color(0xFF10B981),
                      ),
                      _buildAmbiguityCheckChip(
                        label: 'Made an assumption',
                        checkKey: 'assumption',
                        icon: Icons.warning_amber_rounded,
                        activeColor: const Color(0xFFF59E0B),
                      ),
                      _buildAmbiguityCheckChip(
                        label: 'Gave unsupported answer',
                        checkKey: 'unsupported',
                        icon: Icons.error_outline_rounded,
                        activeColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmbiguityCheckChip({
    required String label,
    required String checkKey,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isChecked = selectedAmbiguityChecks.contains(checkKey);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isChecked ? Colors.white : activeColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
              color: isChecked ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
      selected: isChecked,
      selectedColor: activeColor.withValues(alpha: 0.3),
      backgroundColor: const Color(0xFF0F172A),
      side: BorderSide(
        color: isChecked ? activeColor : Colors.white12,
        width: isChecked ? 1.5 : 1,
      ),
      onSelected: (_) => onAmbiguityCheckToggled(checkKey),
    );
  }
}
