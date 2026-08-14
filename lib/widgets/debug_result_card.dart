import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/software_ai_result.dart';
import '../theme/app_theme.dart';

/// DebugResultCard renders bug diagnosis and corrected code from AI Code Debugging.
class DebugResultCard extends StatelessWidget {
  final SoftwareAiResult result;
  final String language;

  const DebugResultCard({
    super.key,
    required this.result,
    this.language = 'Python',
  });

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accentPurple, size: 16),
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

  @override
  Widget build(BuildContext context) {
    final fixedCode = result.extractCodeBlock(language);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
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
                  color: AppTheme.accentPurple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bug_report_rounded, color: AppTheme.accentPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI BUG ANALYSIS & DIAGNOSIS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Model: ${result.model} • ${result.executionTimeMs}ms',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _copy(context, fixedCode, 'Fixed code'),
                icon: const Icon(Icons.copy, size: 12),
                label: Text('📋 FIXED CODE', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Corrected Code Box
          Text(
            'CORRECTED CODE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentPurple,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                fixedCode,
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  color: const Color(0xFFE2E8F0),
                  height: 1.45,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Bug Diagnosis Breakdown Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FULL DIAGNOSIS & FIX EXPLANATION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPurple,
                  letterSpacing: 0.8,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.accentPurple),
                onPressed: () => _copy(context, result.output, 'Bug analysis'),
                tooltip: 'Copy Analysis',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SelectableText(
              result.output.trim(),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
