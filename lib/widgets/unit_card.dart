import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/material_model.dart';
import '../services/progress_storage_service.dart';
import '../theme/app_theme.dart';
import 'topic_card.dart';

/// UnitCard represents an expandable GTU Syllabus Unit container containing topics.
class UnitCard extends StatefulWidget {
  final UnitModel unit;
  final VoidCallback onToggleComplete;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onToggleComplete,
  });

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ProgressStorageService.progressChangeNotifier,
      builder: (context, val, child) {
        final isComp = ProgressStorageService.isUnitCompletedSync(widget.unit.id);
        final unit = widget.unit.copyWith(isCompleted: isComp);

        return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? AppTheme.primaryCyan.withValues(alpha: 0.5)
              : unit.isCompleted
                  ? AppTheme.secondaryTeal.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
          width: _isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? AppTheme.primaryCyan.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Collapsed Unit Header
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.logoGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'UNIT ${unit.number}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Specs
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppTheme.academicGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${unit.hours} Hours',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.academicGold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.topic_outlined,
                                size: 12,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${unit.topics.length} Topics',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Expand Chevron
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Unit Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 6),

                          Text(
                            unit.shortDescription,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'SYLLABUS TOPICS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryCyan,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 10),

                          ...unit.topics.map(
                            (topic) => TopicCard(topic: topic),
                          ),

                          const SizedBox(height: 10),

                          // Mark Completed Toggle
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                widget.onToggleComplete();
                                final isNowDone = !unit.isCompleted;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isNowDone
                                        ? '✓ GTU Unit ${unit.number} marked as completed.'
                                        : 'GTU Unit ${unit.number} marked as incomplete.'),
                                    backgroundColor: isNowDone
                                        ? AppTheme.secondaryTeal
                                        : Colors.grey[800],
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: Icon(
                                unit.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 16,
                              ),
                              label: Text(
                                unit.isCompleted
                                    ? 'UNIT COMPLETED ✓'
                                    : 'MARK UNIT AS COMPLETED',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: unit.isCompleted
                                    ? AppTheme.secondaryTeal
                                    : AppTheme.textPrimary,
                                side: BorderSide(
                                  color: unit.isCompleted
                                      ? AppTheme.secondaryTeal
                                      : Colors.white24,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  },
);
}
}
