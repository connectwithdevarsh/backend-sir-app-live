import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chain_result.dart';
import '../models/reasoning_result.dart';
import '../theme/app_theme.dart';

/// TechniqueComparisonCard renders a side-by-side comparative analysis matrix
/// for Structured Reasoning (CoT) vs Prompt Chaining.
class TechniqueComparisonCard extends StatelessWidget {
  final ReasoningResult structuredResult;
  final ChainResult chainResult;
  final Map<String, String> evaluationRatings;
  final Function(String key, String value) onRatingChanged;

  const TechniqueComparisonCard({
    super.key,
    required this.structuredResult,
    required this.chainResult,
    required this.evaluationRatings,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final criteria = [
      {'key': 'clarity', 'label': 'Step Clarity'},
      {'key': 'quality', 'label': 'Final Answer Quality'},
      {'key': 'structure', 'label': 'Output Structure'},
      {'key': 'error_detection', 'label': 'Error Detection'},
      {'key': 'completion', 'label': 'Task Completion'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.compare_arrows_rounded, color: AppTheme.primaryCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TECHNIQUE COMPARISON MATRIX',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Structured Reasoning (CoT) vs Prompt Chaining',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Side-by-Side Final Output Comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Structured Reasoning Output
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_tree_rounded, size: 14, color: AppTheme.secondaryTeal),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'STRUCTURED REASONING',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 Request • ${structuredResult.executionTimeMs}ms',
                        style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        structuredResult.finalAnswer.trim(),
                        maxLines: 8,
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Right: Prompt Chaining Output
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 14, color: AppTheme.accentViolet),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'PROMPT CHAINING',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentViolet,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${chainResult.steps.length} Steps • ${chainResult.totalExecutionTimeMs}ms',
                        style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        chainResult.finalOutput.trim(),
                        maxLines: 8,
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Student Comparative Evaluation Rating Chips
          Text(
            'STUDENT COMPARATIVE EVALUATION',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Column(
            children: criteria.map((item) {
              final key = item['key']!;
              final label = item['label']!;
              final currentVal = evaluationRatings[key] ?? 'Similar';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: ['CoT Preferred', 'Similar', 'Chain Preferred'].map((val) {
                          final isSel = currentVal == val;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: ChoiceChip(
                              label: Text(val),
                              selected: isSel,
                              onSelected: (_) => onRatingChanged(key, val),
                              selectedColor: AppTheme.primaryCyan,
                              backgroundColor: const Color(0xFF0F172A),
                              side: BorderSide(
                                color: isSel ? AppTheme.primaryCyan : Colors.white12,
                              ),
                              labelStyle: GoogleFonts.spaceGrotesk(
                                fontSize: 9.5,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? Colors.black : AppTheme.textMuted,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
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
