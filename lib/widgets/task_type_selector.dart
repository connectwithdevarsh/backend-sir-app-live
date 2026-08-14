import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// TaskTypeSelector builds the premium tab selector for switching between
/// Summarization, Blog Generation, and Code Generation tasks.
class TaskTypeSelector extends StatelessWidget {
  final String? selectedTask;
  final String? selectedTaskType;
  final ValueChanged<String>? onTaskChanged;
  final ValueChanged<String>? onTaskTypeChanged;
  final bool isEnabled;

  const TaskTypeSelector({
    super.key,
    this.selectedTask,
    this.selectedTaskType,
    this.onTaskChanged,
    this.onTaskTypeChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final String activeTask = selectedTask ?? selectedTaskType ?? 'summarization';

    final tasks = [
      {
        'key': 'summarization',
        'title': 'SUMMARIZATION',
        'subtitle': 'Shorten & Format',
        'color': AppTheme.primaryCyan,
        'icon': Icons.compress_rounded,
      },
      {
        'key': 'blog',
        'title': 'BLOG GENERATION',
        'subtitle': 'Articles & Posts',
        'color': AppTheme.secondaryTeal,
        'icon': Icons.article_rounded,
      },
      {
        'key': 'code',
        'title': 'CODE GENERATION',
        'subtitle': 'Programs & Logic',
        'color': AppTheme.accentViolet,
        'icon': Icons.code_rounded,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: tasks.map((t) {
          final key = t['key'] as String;
          final title = t['title'] as String;
          final subtitle = t['subtitle'] as String;
          final color = t['color'] as Color;
          final icon = t['icon'] as IconData;
          final isSelected = activeTask.toLowerCase() == key;

          return Expanded(
            child: InkWell(
              onTap: isEnabled
                  ? () {
                      if (onTaskChanged != null) onTaskChanged!(key);
                      if (onTaskTypeChanged != null) onTaskTypeChanged!(key);
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: isSelected ? color : AppTheme.textMuted),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: isSelected ? color : AppTheme.textMuted.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
