import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// QueryCategorySelector provides a segmented selector for
/// FACTUAL, LOGICAL, and AMBIGUOUS query categories.
class QueryCategorySelector extends StatelessWidget {
  final String selectedCategory; // "factual", "logical", "ambiguous"
  final ValueChanged<String> onCategoryChanged;
  final bool isEnabled;

  const QueryCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
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
          // FACTUAL
          Expanded(
            child: _buildCategoryTab(
              key: 'factual',
              label: 'Factual',
              icon: Icons.fact_check_rounded,
              activeColor: AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(width: 4),

          // LOGICAL
          Expanded(
            child: _buildCategoryTab(
              key: 'logical',
              label: 'Logical',
              icon: Icons.psychology_alt_rounded,
              activeColor: AppTheme.accentPurple,
            ),
          ),
          const SizedBox(width: 4),

          // AMBIGUOUS
          Expanded(
            child: _buildCategoryTab(
              key: 'ambiguous',
              label: 'Ambiguous',
              icon: Icons.help_center_rounded,
              activeColor: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String key,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isSelected = selectedCategory.toLowerCase() == key;

    return InkWell(
      onTap: isEnabled ? () => onCategoryChanged(key) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
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
              size: 15,
              color: isSelected ? activeColor : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
