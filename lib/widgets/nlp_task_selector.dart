import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// NlpTaskSelector provides a segmented control allowing the student
/// to switch between Sentiment Analysis and Text Classification.
class NlpTaskSelector extends StatelessWidget {
  final String selectedTask; // "sentiment" or "classification"
  final ValueChanged<String> onTaskChanged;
  final bool isEnabled;

  const NlpTaskSelector({
    super.key,
    required this.selectedTask,
    required this.onTaskChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // SENTIMENT ANALYSIS TAB
          Expanded(
            child: _buildSegmentButton(
              taskKey: 'sentiment',
              label: 'Sentiment Analysis',
              icon: Icons.sentiment_satisfied_alt_rounded,
            ),
          ),
          const SizedBox(width: 4),

          // TEXT CLASSIFICATION TAB
          Expanded(
            child: _buildSegmentButton(
              taskKey: 'classification',
              label: 'Text Classification',
              icon: Icons.category_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String taskKey,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = selectedTask == taskKey;

    return InkWell(
      onTap: isEnabled ? () => onTaskChanged(taskKey) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryCyan.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCyan : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryCyan : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryCyan : AppTheme.textMuted,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
