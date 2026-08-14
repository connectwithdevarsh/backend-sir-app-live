import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rag_response.dart';
import '../theme/app_theme.dart';

/// RagAnswerCard displays AI-generated grounded answers for Practical 11.
class RagAnswerCard extends StatelessWidget {
  final RagResponse response;

  const RagAnswerCard({
    super.key,
    required this.response,
  });

  void _copyAnswer(BuildContext context) {
    Clipboard.setData(ClipboardData(text: response.answer));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.secondaryTeal, size: 16),
            const SizedBox(width: 8),
            Text('Answer copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
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
    final bool isUnfound = response.answer.toLowerCase().contains('could not be found');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnfound
              ? Colors.amber.withValues(alpha: 0.5)
              : AppTheme.secondaryTeal.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isUnfound ? Colors.amber : AppTheme.secondaryTeal).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnfound ? Icons.info_outline_rounded : Icons.auto_awesome_rounded,
                  color: isUnfound ? Colors.amber : AppTheme.secondaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnfound ? 'GROUNDED RAG RESPONSE' : 'GROUNDED AI ANSWER',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Model: ${response.model} • ${response.executionTimeMs}ms',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _copyAnswer(context),
                icon: const Icon(Icons.copy, size: 12),
                label: Text('📋 COPY ANSWER', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnfound ? Colors.amber : AppTheme.secondaryTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Answer Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnfound
                    ? Colors.amber.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: SelectableText(
              response.answer.trim(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isUnfound ? Colors.amber : const Color(0xFFE2E8F0),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
