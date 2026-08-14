import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/material_model.dart';
import '../theme/app_theme.dart';

/// TopicCard renders an expandable topic item containing subtopics and Learning Notes.
class TopicCard extends StatefulWidget {
  final TopicModel topic;

  const TopicCard({super.key, required this.topic});

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isExpanded
              ? AppTheme.primaryCyan.withValues(alpha: 0.4)
              : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          // Topic Header Row
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic.id,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryCyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.remove_circle_outline_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 18,
                    color: _isExpanded
                        ? AppTheme.primaryCyan
                        : AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details Section
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 6),
                        ...topic.subtopics.map(
                          (sub) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppTheme.secondaryTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    sub,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (topic.learningNotes != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.academicGold
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 14,
                                  color: AppTheme.academicGold,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    topic.learningNotes!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textPrimary,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
