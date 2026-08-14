import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// ReferenceAnswerCard allows students to supply an optional ground truth or expected behavior
/// for evaluation and comparison against the actual LLM output.
class ReferenceAnswerCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;

  const ReferenceAnswerCard({
    super.key,
    required this.controller,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
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
                  Icons.verified_user_outlined,
                  color: AppTheme.secondaryTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'REFERENCE / EXPECTED ANSWER',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  'OPTIONAL',
                  style: GoogleFonts.firaCode(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Supply the expected ground truth or expected behavior (e.g., "Paris" or "Model should ask for clarification").',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Editable Reference TextField
          TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: 2,
            minLines: 1,
            style: GoogleFonts.firaCode(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Paris, or "Expected behavior: ask for clarification"',
              hintStyle: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.white24,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0F1D),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppTheme.secondaryTeal,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
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
