import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/study_plan_item.dart';
import '../theme/app_theme.dart';

/// StudyPlanCard displays day-by-day study schedule items for Practical 12.
class StudyPlanCard extends StatelessWidget {
  final List<StudyPlanItem> items;

  const StudyPlanCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppTheme.secondaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'PERSONALIZED AI STUDY SCHEDULE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DAY ${item.day}',
                            style: GoogleFonts.firaCode(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryCyan,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.subject,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryTeal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.duration,
                            style: GoogleFonts.firaCode(
                              fontSize: 10,
                              color: AppTheme.secondaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Focus: ${item.topic}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Activity: ${item.activity}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                        height: 1.35,
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
}
