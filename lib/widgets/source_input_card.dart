import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// SourceInputCard builds the input editor for source text, topic, or problem statement.
class SourceInputCard extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final bool isEnabled;
  final VoidCallback onClear;

  const SourceInputCard({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.isEnabled,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppTheme.primaryCyan, size: 18),
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
              ),
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16, color: AppTheme.textMuted),
                onPressed: isEnabled ? onClear : null,
                tooltip: 'Clear Input',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: 4,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.white,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryCyan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
