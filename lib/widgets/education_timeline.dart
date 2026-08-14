import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/faculty_model.dart';
import '../theme/app_theme.dart';

/// EducationTimeline renders a vertical timeline for academic qualifications.
class EducationTimeline extends StatelessWidget {
  final List<QualificationItem> qualifications;

  const EducationTimeline({
    super.key,
    required this.qualifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: qualifications.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final bool isLast = idx == qualifications.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Column Indicator
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.year,
                      style: GoogleFonts.firaCode(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.degree,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.institution,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
