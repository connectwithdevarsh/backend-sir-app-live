import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_prompt_result.dart';
import '../theme/app_theme.dart';

/// TaskComparisonCard renders Before vs After output comparison,
/// student comparative evaluation ratings, and optimization checklist.
class TaskComparisonCard extends StatelessWidget {
  final TaskPromptResult basicResult;
  final TaskPromptResult optimizedResult;
  final Map<String, String> evaluationRatings;
  final Function(String key, String value) onRatingChanged;
  final Map<String, bool> improvementChecklist;
  final Function(String key, bool val) onChecklistChanged;

  const TaskComparisonCard({
    super.key,
    required this.basicResult,
    required this.optimizedResult,
    required this.evaluationRatings,
    required this.onRatingChanged,
    required this.improvementChecklist,
    required this.onChecklistChanged,
  });

  @override
  Widget build(BuildContext context) {
    final criteria = [
      {'key': 'relevance', 'label': 'Topic / Task Relevance'},
      {'key': 'structure', 'label': 'Output Structure & Formatting'},
      {'key': 'audience', 'label': 'Audience / Tone Suitability'},
      {'key': 'clarity', 'label': 'Clarity & Completeness'},
      {'key': 'constraints', 'label': 'Instruction & Constraint Following'},
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
                child: const Icon(Icons.compare_rounded, color: AppTheme.primaryCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BEFORE vs AFTER COMPARISON',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Basic Prompt Output vs Optimized Prompt Output',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Side-by-Side Outputs
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Basic Output
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEFORE (BASIC PROMPT)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${basicResult.executionTimeMs}ms',
                        style: GoogleFonts.inter(fontSize: 9.5, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        basicResult.output.trim(),
                        maxLines: 8,
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Right: Optimized Output
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
                      Text(
                        'AFTER (OPTIMIZED PROMPT)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${optimizedResult.executionTimeMs}ms',
                        style: GoogleFonts.inter(fontSize: 9.5, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        optimizedResult.output.trim(),
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

          // Student Comparative Ratings
          Text(
            'STUDENT EVALUATION CRITERIA',
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
              final currentVal = evaluationRatings[key] ?? 'Better';

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
                        children: ['Better', 'Similar', 'Needs Work'].map((val) {
                          final isSel = currentVal == val;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: ChoiceChip(
                              label: Text(val),
                              selected: isSel,
                              onSelected: (_) => onRatingChanged(key, val),
                              selectedColor: AppTheme.secondaryTeal,
                              backgroundColor: const Color(0xFF0F172A),
                              side: BorderSide(
                                color: isSel ? AppTheme.secondaryTeal : Colors.white12,
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
          const SizedBox(height: 16),

          // Collapsible "WHAT WAS IMPROVED?" Checklist
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              title: Text(
                'WHAT WAS IMPROVED? (Checklist)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    children: improvementChecklist.entries.map((entry) {
                      return CheckboxListTile(
                        value: entry.value,
                        title: Text(entry.key, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                        activeColor: AppTheme.secondaryTeal,
                        checkColor: Colors.black,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => onChecklistChanged(entry.key, val ?? false),
                      );
                    }).toList(),
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
