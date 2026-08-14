import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_result.dart';
import '../theme/app_theme.dart';
import 'prompt_viewer.dart';

/// PromptResultCard displays the live AI response, model name, execution latency,
/// and includes an expandable PromptViewer to inspect the prompt structure.
class PromptResultCard extends StatelessWidget {
  final PromptResult result;
  final String cardTitle;
  final Color accentColor;

  const PromptResultCard({
    super.key,
    required this.result,
    required this.cardTitle,
    this.accentColor = AppTheme.primaryCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: TITLE + COPY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_rounded, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    cardTitle.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.output));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Response copied to clipboard'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(Icons.copy_rounded, size: 13, color: accentColor),
                label: Text(
                  'COPY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 18),

          // MODEL & LATENCY BADGES
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPill(
                icon: Icons.memory_rounded,
                label: 'Model: ${result.model}',
                color: AppTheme.primaryCyan,
              ),
              _buildPill(
                icon: Icons.timer_rounded,
                label: 'Latency: ${result.executionTimeMs} ms',
                color: AppTheme.academicGold,
              ),
              _buildPill(
                icon: Icons.check_circle_rounded,
                label: 'Status: 200 OK',
                color: const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // RESPONSE TEXT CONTAINER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: SelectableText(
              result.output.trim(),
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // RAW PROMPT INSPECTOR
          if (result.prompt.isNotEmpty)
            PromptViewer(
              title: 'VIEW EXACT PROMPT SENT TO AI',
              prompt: result.prompt,
            ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
