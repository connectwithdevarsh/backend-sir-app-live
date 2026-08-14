import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/faculty_model.dart';
import '../services/progress_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/education_timeline.dart';
import '../widgets/experience_timeline.dart';
import '../widgets/faculty_info_card.dart';
import '../widgets/faculty_profile_header.dart';
import '../widgets/interest_chip.dart';

/// FacultyProfileScreen displays the official academic profile for Dr. Dippal P. Israni.
class FacultyProfileScreen extends StatefulWidget {
  const FacultyProfileScreen({super.key});

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FacultyModel faculty = FacultyModel.currentFaculty;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'FACULTY PROFILE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Profile Header
                  FacultyProfileHeader(faculty: faculty),

                  const SizedBox(height: 24),

                  // Faculty Introduction Section
                  _buildSectionHeader('FACULTY PROFILE', Icons.person_outline_rounded),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Text(
                      faculty.bio,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFFE2E8F0),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Information Cards
                  FacultyInfoCard(faculty: faculty),

                  const SizedBox(height: 20),

                  // Areas of Interest Section
                  _buildSectionHeader('AREAS OF INTEREST', Icons.psychology_rounded),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: faculty.areasOfInterest.map((interest) {
                      return InterestChip(label: interest);
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Education Timeline Section
                  _buildSectionHeader('EDUCATION', Icons.school_rounded),
                  const SizedBox(height: 12),
                  EducationTimeline(qualifications: faculty.qualifications),

                  const SizedBox(height: 24),

                  // Professional Experience Timeline Section
                  _buildSectionHeader('PROFESSIONAL EXPERIENCE', Icons.work_rounded),
                  const SizedBox(height: 12),
                  ExperienceTimeline(experiences: faculty.experiences),

                  const SizedBox(height: 24),

                  // Professional Membership Section
                  _buildSectionHeader('PROFESSIONAL MEMBERSHIP', Icons.card_membership_rounded),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: AppTheme.secondaryTeal,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                faculty.membership.organization,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                faculty.membership.detail,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Research & Academic Interest Section
                  _buildSectionHeader('RESEARCH & ACADEMIC INTERESTS', Icons.hub_rounded),
                  const SizedBox(height: 10),
                  Column(
                    children: faculty.areasOfInterest.map((interest) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.science_rounded,
                              size: 16,
                              color: AppTheme.primaryCyan,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              interest,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Reset Progress Settings Section
                  _buildSectionHeader('PRACTICAL PROGRESS & SETTINGS', Icons.settings_rounded),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<int>(
                    valueListenable: ProgressStorageService.progressChangeNotifier,
                    builder: (context, val, child) {
                      final count = ProgressStorageService.getCompletedCountSync();
                      final pct = ProgressStorageService.getProgressPercentageSync();
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$count of 12 Practicals Completed',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Progress: ${pct.toStringAsFixed(1)}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: AppTheme.primaryCyan,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showResetProgressDialog(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              label: Text(
                                'RESET',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset all practical progress?',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'This action will clear all 12 saved practical completion records from local device storage. Are you sure?',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ProgressStorageService.clearAllProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All practical progress has been reset.'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(
              'RESET',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryCyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryCyan,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
