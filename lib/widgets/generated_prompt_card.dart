import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// GeneratedPromptCard displays the exact compiled prompt sent to the LLM backend.
class GeneratedPromptCard extends StatelessWidget {
  final String title;
  final String promptText;
  final Color accentColor;

  const GeneratedPromptCard({
    super.key,
    required this.title,
    required this.promptText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(Icons.code_rounded, size: 18, color: accentColor),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Inspect exact constructed LLM prompt',
          style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
              tooltip: 'Copy constructed prompt',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: promptText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Prompt copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppTheme.surfaceDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Icon(Icons.expand_more_rounded, color: Colors.white60, size: 20),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: SelectableText(
                promptText.isNotEmpty ? promptText : '(No prompt compiled)',
                style: GoogleFonts.firaCode(
                  fontSize: 11.5,
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
