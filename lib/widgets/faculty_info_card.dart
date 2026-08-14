import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/faculty_model.dart';
import '../theme/app_theme.dart';

/// FacultyInfoCard renders quick information metrics for Dr. Dippal P. Israni.
class FacultyInfoCard extends StatelessWidget {
  final FacultyModel faculty;

  const FacultyInfoCard({
    super.key,
    required this.faculty,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.school_rounded,
        'title': 'QUALIFICATION',
        'subtitle': faculty.qualification.split('(').first.trim(),
        'color': AppTheme.primaryCyan,
      },
      {
        'icon': Icons.work_rounded,
        'title': 'DESIGNATION',
        'subtitle': faculty.designation,
        'color': AppTheme.secondaryTeal,
      },
      {
        'icon': Icons.calendar_month_rounded,
        'title': 'JOINED',
        'subtitle': faculty.dateOfJoining,
        'color': Colors.amber,
      },
      {
        'icon': Icons.psychology_rounded,
        'title': 'RESEARCH INTERESTS',
        'subtitle': faculty.areasOfInterest.join(', '),
        'color': AppTheme.primaryCyan,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final icon = item['icon'] as IconData;
        final title = item['title'] as String;
        final subtitle = item['subtitle'] as String;
        final color = item['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
