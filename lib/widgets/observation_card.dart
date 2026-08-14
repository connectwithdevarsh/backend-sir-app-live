import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// ObservationCard provides guidelines for analyzing prompt refinement results
/// and an editable multiline field for students to record their laboratory notes.
class ObservationCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;

  const ObservationCard({
    super.key,
    required this.controller,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final guidelines = [
      'Did the refined prompt eliminate ambiguity regarding tone and structure?',
      'Did adding clear constraints reduce hallucinations or extraneous text?',
      'How did specifying the target audience alter the complexity of vocabulary?',
      'Did the output format match the requested structure (e.g. subject, bullets)?',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryTeal.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rate_review_outlined,
                  color: AppTheme.secondaryTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'STUDENT OBSERVATION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'GTU LAB NOTES',
                  style: GoogleFonts.firaCode(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTeal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Analysis Guidelines
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytical Observation Guide:',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                ...guidelines.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppTheme.secondaryTeal,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Observation Textfield
          Text(
            'Your Observation & Conclusion:',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.white,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Describe how refining the prompt improved clarity, structure, and alignment...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF0A0F1D),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondaryTeal, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
