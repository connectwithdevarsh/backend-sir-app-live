import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chain_result.dart';
import '../theme/app_theme.dart';

/// ChainStepResult renders the timeline of executed prompt chain steps.
class ChainStepResult extends StatelessWidget {
  final ChainResult result;

  const ChainStepResult({
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
            const Icon(Icons.check_circle, color: AppTheme.accentViolet, size: 16),
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

  void _showPromptDialog(BuildContext context, String title, String prompt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.spaceGrotesk(color: AppTheme.accentViolet, fontSize: 16)),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: SelectableText(
              prompt,
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
              _copy(context, prompt, 'Prompt');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy, size: 14),
            label: Text('Copy Prompt', style: GoogleFonts.inter(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentViolet),
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
        border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentViolet.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.link_rounded, color: AppTheme.accentViolet, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROMPT CHAIN RESULT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${result.steps.length} Sequential Requests • ${result.totalExecutionTimeMs}ms Total',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  ],
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

          // Steps Timeline List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.steps.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
              child: Row(
                children: [
                  Container(width: 2, height: 16, color: AppTheme.accentViolet.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_downward_rounded, size: 14, color: AppTheme.accentViolet.withValues(alpha: 0.6)),
                ],
              ),
            ),
            itemBuilder: (context, index) {
              final step = result.steps[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Top Bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentViolet.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'STEP ${step.stepNumber}',
                            style: GoogleFonts.firaCode(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentViolet,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${step.executionTimeMs}ms',
                          style: GoogleFonts.firaCode(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Actions Bar (View Prompt, Copy Prompt, Copy Output)
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showPromptDialog(context, step.name, step.prompt),
                          icon: const Icon(Icons.visibility_outlined, size: 13),
                          label: Text('View Prompt', style: GoogleFonts.inter(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppTheme.accentViolet,
                            side: BorderSide(color: AppTheme.accentViolet.withValues(alpha: 0.4)),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryCyan),
                          onPressed: () => _copy(context, step.output, 'Step ${step.stepNumber} output'),
                          tooltip: 'Copy Output',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Output Text Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: SelectableText(
                        step.output.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFFE2E8F0),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
