import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/faculty_model.dart';
import '../theme/app_theme.dart';

/// ExperienceTimeline renders a vertical timeline for professional teaching experience.
class ExperienceTimeline extends StatelessWidget {
  final List<ExperienceItem> experiences;

  const ExperienceTimeline({
    super.key,
    required this.experiences,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: experiences.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final bool isLast = idx == experiences.length - 1;

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
                    color: AppTheme.secondaryTeal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryTeal.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: AppTheme.secondaryTeal.withValues(alpha: 0.3),
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
                      item.duration,
                      style: GoogleFonts.firaCode(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.institution,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.role,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryTeal,
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
