import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// SoftwareTaskSelector builds the tab selector for switching between
/// Code Generation, Code Debugging, and Code Explanation features.
class SoftwareTaskSelector extends StatelessWidget {
  final String selectedTask; // "code_generation", "debugging", "code_explanation"
  final ValueChanged<String> onTaskChanged;
  final bool isEnabled;

  const SoftwareTaskSelector({
    super.key,
    required this.selectedTask,
    required this.onTaskChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        'key': 'code_generation',
        'title': 'CODE GENERATION',
        'subtitle': 'Build Programs',
        'color': AppTheme.primaryCyan,
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'key': 'debugging',
        'title': 'DEBUG CODE',
        'subtitle': 'Find & Fix Bugs',
        'color': AppTheme.accentPurple,
        'icon': Icons.bug_report_rounded,
      },
      {
        'key': 'code_explanation',
        'title': 'EXPLAIN CODE',
        'subtitle': 'Logic & Purpose',
        'color': AppTheme.secondaryTeal,
        'icon': Icons.lightbulb_rounded,
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
          final isSelected = selectedTask == key;

          return Expanded(
            child: InkWell(
              onTap: isEnabled ? () => onTaskChanged(key) : null,
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
