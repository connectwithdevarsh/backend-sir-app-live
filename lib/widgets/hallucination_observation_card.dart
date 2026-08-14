import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// HallucinationObservationCard presents guidelines for hallucination identification
/// and provides an editable text area for students to record their analytical notes.
class HallucinationObservationCard extends StatelessWidget {
  final TextEditingController observationController;
  final bool isEnabled;

  const HallucinationObservationCard({
    super.key,
    required this.observationController,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> checkItems = [
      'Is the generated response factually supported by established sources?',
      'Does it contain fabricated or unverified claims (hallucinations)?',
      'Does the model assert confidence on uncertain or ambiguous topics?',
      'Does the logical deduction accurately follow the provided premises?',
      'Does the model handle lack of context properly without assuming intent?',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEC4899).withValues(alpha: 0.35),
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
                  color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.policy_outlined,
                  color: Color(0xFFEC4899),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'HALLUCINATION CHECK',
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
                  color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'GTU OBSERVATION',
                  style: GoogleFonts.firaCode(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEC4899),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Evaluation Checklist Guide
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
                  'Key Evaluation Questions to Verify:',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                ...checkItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFFEC4899),
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

          // Student Observation Notes Textarea
          Text(
            'Student Observation & Remarks:',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: observationController,
            enabled: isEnabled,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.white,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Record whether the model was accurate, made an assumption, or hallucinated facts...',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white24,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0F1D),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEC4899),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
