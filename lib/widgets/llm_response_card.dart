import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/llm_evaluation_result.dart';
import '../theme/app_theme.dart';

/// LLMResponseCard displays the real LLM output, model metadata, execution latency,
/// and reference comparison analysis.
class LLMResponseCard extends StatelessWidget {
  final LLMEvaluationResult result;

  const LLMResponseCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasReference = result.referenceAnswer.isNotEmpty;
    final assisted = result.assistedEvaluation;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  color: AppTheme.primaryCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'MODEL RESPONSE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),

                // Latency Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 11,
                        color: AppTheme.primaryCyan,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${result.executionTimeMs} ms',
                        style: GoogleFonts.firaCode(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Copy Action Button
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 17,
                    color: AppTheme.textMuted,
                  ),
                  tooltip: 'Copy response',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result.response));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Response copied to clipboard',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppTheme.surfaceDark,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Model Name Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.memory_rounded,
                        color: AppTheme.secondaryTeal,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Model: ${result.model}',
                        style: GoogleFonts.firaCode(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Real LLM Output Surface
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080D1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SelectableText(
                    result.response.isNotEmpty
                        ? result.response
                        : '(No output received from model)',
                    style: GoogleFonts.firaCode(
                      fontSize: 13,
                      color: const Color(0xFFE2E8F0),
                      height: 1.55,
                    ),
                  ),
                ),

                // Optional Reference Comparison Area
                if (hasReference) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.secondaryTeal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.compare_rounded,
                              color: AppTheme.secondaryTeal,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GROUND TRUTH / REFERENCE COMPARISON',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Provided Reference:',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0F1D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            result.referenceAnswer,
                            style: GoogleFonts.firaCode(
                              fontSize: 12,
                              color: AppTheme.secondaryTeal,
                            ),
                          ),
                        ),
                        if (assisted != null && assisted.hasReference) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.accentPurple.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.analytics_outlined,
                                      color: AppTheme.accentPurple,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Assisted Observation: ${assisted.status}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  assisted.detail,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  assisted.disclaimer,
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
