import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// CodeEditorCard builds a code or requirement editor container with monospace font.
class CodeEditorCard extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final bool isEnabled;
  final bool isMonospace;
  final int maxLines;
  final VoidCallback onClear;
  final Color accentColor;

  const CodeEditorCard({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.isEnabled,
    this.isMonospace = true,
    this.maxLines = 5,
    required this.onClear,
    this.accentColor = AppTheme.primaryCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isMonospace ? Icons.code_rounded : Icons.edit_note_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16, color: AppTheme.textMuted),
                onPressed: isEnabled ? onClear : null,
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: maxLines,
            style: isMonospace
                ? GoogleFonts.firaCode(fontSize: 12, color: const Color(0xFFE2E8F0), height: 1.4)
                : GoogleFonts.inter(fontSize: 12.5, color: Colors.white, height: 1.4),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: isMonospace
                  ? GoogleFonts.firaCode(fontSize: 11.5, color: AppTheme.textMuted)
                  : GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
              filled: true,
              fillColor: const Color(0xFF0B1120),
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
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
