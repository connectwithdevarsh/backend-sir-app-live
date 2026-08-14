import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reasoning_result.dart';
import '../theme/app_theme.dart';

/// ReasoningResultCard renders the result of a Structured Reasoning (Chain-of-Thought style) execution.
class ReasoningResultCard extends StatelessWidget {
  final ReasoningResult result;

  const ReasoningResultCard({
    super.key,
    required this.result,
  });

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.secondaryTeal, size: 16),
            const SizedBox(width: 8),
            Text('$label copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Structured Reasoning Prompt', style: GoogleFonts.spaceGrotesk(color: AppTheme.secondaryTeal, fontSize: 16)),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: SelectableText(
              result.prompt,
              style: GoogleFonts.firaCode(fontSize: 11.5, color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _copy(context, result.prompt, 'Prompt');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy, size: 14),
            label: Text('Copy Prompt', style: GoogleFonts.inter(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryTeal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_tree_rounded, color: AppTheme.secondaryTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STRUCTURED REASONING RESULT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Model: ${result.model} • ${result.executionTimeMs}ms',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showPromptDialog(context),
                icon: const Icon(Icons.visibility_outlined, size: 13),
                label: Text('View Prompt', style: GoogleFonts.inter(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  foregroundColor: AppTheme.secondaryTeal,
                  side: BorderSide(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Error Banner if failed
          if (!result.success && result.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.error!,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Intermediate Steps Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INTERMEDIATE REASONING STEPS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.secondaryTeal),
                onPressed: () => _copy(context, result.intermediateSteps, 'Intermediate steps'),
                tooltip: 'Copy Steps',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SelectableText(
              result.intermediateSteps,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFFE2E8F0),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Final Answer Box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINAL ANSWER',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                  letterSpacing: 0.8,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryCyan),
                onPressed: () => _copy(context, result.finalAnswer, 'Final answer'),
                tooltip: 'Copy Final Answer',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
            ),
            child: SelectableText(
              result.finalAnswer,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
