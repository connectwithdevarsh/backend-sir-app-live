import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// InterestChip renders area of interest tags with distinct icons.
class InterestChip extends StatelessWidget {
  final String label;

  const InterestChip({
    super.key,
    required this.label,
  });

  IconData _getIconForInterest(String interest) {
    final lower = interest.toLowerCase();
    if (lower.contains('machine learning')) {
      return Icons.psychology_rounded;
    } else if (lower.contains('computer vision')) {
      return Icons.visibility_rounded;
    } else if (lower.contains('deep learning')) {
      return Icons.hub_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForInterest(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.secondaryTeal),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
