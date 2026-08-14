import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// TechniqueSelector builds the pill selector for selecting between
/// Structured Reasoning, Prompt Chaining, or Compare Both mode.
class TechniqueSelector extends StatelessWidget {
  final String selectedMethod; // "structured_reasoning", "prompt_chaining", "compare"
  final ValueChanged<String> onMethodChanged;
  final bool isEnabled;

  const TechniqueSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'key': 'compare',
        'title': 'Compare Both',
        'subtitle': 'Run CoT & Chaining',
        'color': AppTheme.primaryCyan,
        'icon': Icons.compare_arrows_rounded,
      },
      {
        'key': 'structured_reasoning',
        'title': 'Structured Reasoning',
        'subtitle': 'Chain-of-Thought Style',
        'color': AppTheme.secondaryTeal,
        'icon': Icons.account_tree_rounded,
      },
      {
        'key': 'prompt_chaining',
        'title': 'Prompt Chaining',
        'subtitle': 'Sequential Multi-Prompt',
        'color': AppTheme.accentViolet,
        'icon': Icons.link_rounded,
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
        children: options.map((opt) {
          final key = opt['key'] as String;
          final title = opt['title'] as String;
          final subtitle = opt['subtitle'] as String;
          final color = opt['color'] as Color;
          final icon = opt['icon'] as IconData;
          final isSelected = selectedMethod == key;

          return Expanded(
            child: InkWell(
              onTap: isEnabled ? () => onMethodChanged(key) : null,
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
                        fontSize: 11,
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
