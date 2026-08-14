import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// PromptEditorCard renders an editable prompt card for Basic or Optimized prompts.
class PromptEditorCard extends StatelessWidget {
  final String title;
  final String promptType; // "basic" or "optimized"
  final String? badgeText;
  final String? helperText;
  final TextEditingController controller;
  final Color? accentColor;
  final IconData? icon;
  final bool isEnabled;

  const PromptEditorCard({
    super.key,
    required this.title,
    this.promptType = 'basic',
    this.badgeText,
    this.helperText,
    required this.controller,
    this.accentColor,
    this.icon,
    required this.isEnabled,
  });

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primaryCyan, size: 16),
            const SizedBox(width: 8),
            Text('Prompt copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOpt = promptType == 'optimized';
    final Color effectiveAccent = accentColor ?? (isOpt ? AppTheme.secondaryTeal : AppTheme.primaryCyan);
    final String displayBadge = badgeText ?? title.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: effectiveAccent),
                const SizedBox(width: 6),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: effectiveAccent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  displayBadge,
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: effectiveAccent,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryCyan),
                onPressed: () => _copy(context, controller.text),
                tooltip: 'Copy Prompt',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              helperText!,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: 4,
            style: GoogleFonts.firaCode(
              fontSize: 11.5,
              color: const Color(0xFFE2E8F0),
              height: 1.4,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF070B15),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
