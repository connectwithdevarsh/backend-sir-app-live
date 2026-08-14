import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// PromptingMethodSelector provides a 3-way segmented control for
/// ZERO-SHOT, FEW-SHOT, and COMPARE BOTH.
class PromptingMethodSelector extends StatelessWidget {
  final String selectedMethod; // "zero_shot", "few_shot", or "compare"
  final ValueChanged<String> onMethodChanged;
  final bool isEnabled;

  const PromptingMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
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
          // ZERO-SHOT TAB
          Expanded(
            child: _buildSegmentButton(
              methodKey: 'zero_shot',
              label: 'Zero-Shot',
              icon: Icons.bolt_rounded,
            ),
          ),
          const SizedBox(width: 4),

          // FEW-SHOT TAB
          Expanded(
            child: _buildSegmentButton(
              methodKey: 'few_shot',
              label: 'Few-Shot',
              icon: Icons.auto_awesome_rounded,
            ),
          ),
          const SizedBox(width: 4),

          // COMPARE BOTH TAB
          Expanded(
            child: _buildSegmentButton(
              methodKey: 'compare',
              label: 'Compare Both',
              icon: Icons.compare_arrows_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String methodKey,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = selectedMethod == methodKey;

    return InkWell(
      onTap: isEnabled ? () => onMethodChanged(methodKey) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
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
              size: 15,
              color: isSelected ? AppTheme.primaryCyan : AppTheme.textMuted,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
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
