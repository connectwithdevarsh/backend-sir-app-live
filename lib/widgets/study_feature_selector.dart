import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// StudyFeatureSelector provides tab selection across the 5 AI Study Assistant tools.
class StudyFeatureSelector extends StatelessWidget {
  final String selectedTask;
  final ValueChanged<String> onTaskSelected;

  const StudyFeatureSelector({
    super.key,
    required this.selectedTask,
    required this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      {'id': 'explain', 'label': '✨ EXPLAIN', 'desc': 'Concept Explainer'},
      {'id': 'summary', 'label': '📝 SUMMARIZE', 'desc': 'Summary Generator'},
      {'id': 'quiz', 'label': '❓ QUIZ', 'desc': 'Interactive Quiz'},
      {'id': 'study_plan', 'label': '📅 STUDY PLAN', 'desc': 'Day-by-Day Schedule'},
      {'id': 'flashcards', 'label': '🗂 FLASHCARDS', 'desc': 'Revision Flip Cards'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: features.map((f) {
          final id = f['id']!;
          final label = f['label']!;
          final isSelected = selectedTask == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryCyan,
              backgroundColor: AppTheme.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryCyan
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              onSelected: (_) => onTaskSelected(id),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}
