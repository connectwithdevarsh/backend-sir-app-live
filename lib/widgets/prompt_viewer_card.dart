import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// PromptViewerCard displays the exact prompt sent to the LLM.
class PromptViewerCard extends StatelessWidget {
  final String title;
  final String prompt;
  final Color accentColor;

  const PromptViewerCard({
    super.key,
    this.title = 'GENERATED AI PROMPT',
    required this.prompt,
    this.accentColor = AppTheme.primaryCyan,
  });

  void _copyPrompt(BuildContext context) {
    Clipboard.setData(ClipboardData(text: prompt));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primaryCyan, size: 16),
            const SizedBox(width: 8),
            Text('Prompt copied to clipboard successfully', style: GoogleFonts.inter(fontSize: 12)),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _copyPrompt(context),
                icon: const Icon(Icons.copy, size: 12),
                label: Text('COPY PROMPT', style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: SelectableText(
              prompt.trim(),
              style: GoogleFonts.firaCode(
                fontSize: 11.5,
                color: const Color(0xFFE2E8F0),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
