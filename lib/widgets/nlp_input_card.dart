import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// NlpInputCard provides an editable multiline text area for students to input sentences or paragraphs.
class NlpInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final VoidCallback onClear;

  const NlpInputCard({
    super.key,
    required this.controller,
    required this.isEnabled,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: AppTheme.primaryCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ENTER NATURAL-LANGUAGE TEXT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (isEnabled)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 3,
            enabled: isEnabled,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              hintText:
                  'Enter a sentence, review, comment, or short paragraph...',
              hintStyle: GoogleFonts.inter(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryCyan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
