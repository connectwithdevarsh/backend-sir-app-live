import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/faculty_model.dart';
import '../theme/app_theme.dart';

/// FacultyHeader renders the hero section for Dr. Dippal P. Israni.
class FacultyHeader extends StatelessWidget {
  final FacultyModel faculty;

  const FacultyHeader({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Circular Profile Photo
          Semantics(
            label: "Photo of ${faculty.name}",
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryCyan,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/dr_dippal_israni.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.surfaceCard,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primaryCyan,
                        size: 54,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Faculty Name
          Text(
            faculty.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Designation
          Text(
            faculty.designation,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryTeal,
            ),
          ),
          const SizedBox(height: 4),

          // Department & Institution
          Text(
            '${faculty.department} • ${faculty.institution}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
