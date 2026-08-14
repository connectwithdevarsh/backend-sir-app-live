import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/faculty_model.dart';
import '../theme/app_theme.dart';

/// FacultyProfileHeader renders the hero profile section for Dr. Dippal P. Israni.
class FacultyProfileHeader extends StatelessWidget {
  final FacultyModel faculty;

  const FacultyProfileHeader({
    super.key,
    required this.faculty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Photo Frame
        Semantics(
          label: "Photo of ${faculty.name}",
          child: Container(
            width: 140,
            height: 140,
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
                      size: 64,
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
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 4),

        // Designation Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.secondaryTeal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.secondaryTeal.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            faculty.designation.toUpperCase(),
            style: GoogleFonts.firaCode(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTeal,
              letterSpacing: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Department & Institution
        Text(
          'Department of ${faculty.department}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryCyan,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          faculty.institution,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
