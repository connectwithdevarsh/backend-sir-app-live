import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// PromptViewer provides a collapsible terminal card to inspect the exact raw prompt sent to the model.
class PromptViewer extends StatelessWidget {
  final String title;
  final String prompt;
  final VoidCallback? onCopy;

  const PromptViewer({
    super.key,
    required this.title,
    required this.prompt,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (prompt.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: const Icon(
          Icons.code_rounded,
          color: AppTheme.primaryCyan,
          size: 16,
        ),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryCyan,
            letterSpacing: 0.6,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RAW PROMPT DISPATCHED TO AI',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: prompt));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Prompt copied to clipboard'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded,
                                size: 12, color: AppTheme.primaryCyan),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.primaryCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  prompt.trim(),
                  style: GoogleFonts.firaCode(
                    fontSize: 11.5,
                    color: const Color(0xFFE2E8F0),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
