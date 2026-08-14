import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/faculty_data.dart';
import '../models/faculty_model.dart';
import '../theme/app_theme.dart';

/// FacultySubjectCard displays official subject metadata and course highlights
/// (5 units) under the faculty's academic supervision.
class FacultySubjectCard extends StatelessWidget {
  final FacultyModel faculty;

  const FacultySubjectCard({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    final units = FacultyData.getCourseUnits();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: AppTheme.primaryCyan,
              ),
              const SizedBox(width: 8),
              Text(
                'TEACHING & SUBJECT METADATA',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metadata Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildMetaRow('Subject', faculty.subject, isHighlight: true),
                const Divider(color: Colors.white10, height: 16),
                _buildMetaRow('Subject Code', faculty.subjectCode),
                const Divider(color: Colors.white10, height: 16),
                _buildMetaRow('Program', faculty.program),
                const Divider(color: Colors.white10, height: 16),
                _buildMetaRow('Branch', faculty.department),
                const Divider(color: Colors.white10, height: 16),
                _buildMetaRow('Semester', faculty.semester),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Course Unit Highlights Title
          Text(
            'WHAT YOU WILL LEARN (5 SYLLABUS UNITS)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.academicGold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // 5 Compact Unit Cards
          Column(
            children: units.map((u) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.academicGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.academicGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u['number']!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.academicGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        u['title']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? AppTheme.primaryCyan : AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
