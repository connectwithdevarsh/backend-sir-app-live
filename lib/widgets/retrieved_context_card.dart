import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/retrieved_chunk.dart';
import '../theme/app_theme.dart';

/// RetrievedContextCard renders the exact text chunks retrieved from vector search.
class RetrievedContextCard extends StatelessWidget {
  final List<RetrievedChunk> chunks;

  const RetrievedContextCard({
    super.key,
    required this.chunks,
  });

  void _copyChunk(BuildContext context, String text, String chunkId) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.secondaryTeal, size: 16),
            const SizedBox(width: 8),
            Text('$chunkId copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
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
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            const Icon(Icons.find_in_page_rounded, color: AppTheme.secondaryTeal, size: 18),
            const SizedBox(width: 8),
            Text(
              'RETRIEVED CONTEXT (${chunks.length} CHUNKS)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryTeal,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: chunks.asMap().entries.map((entry) {
                final idx = entry.key;
                final chunk = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'CHUNK #${idx + 1} (${chunk.chunkId}) • Page ${chunk.page}',
                              style: GoogleFonts.firaCode(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryTeal,
                              ),
                            ),
                          ),
                          if (chunk.score != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Relevance: ${chunk.score!.toStringAsFixed(4)}',
                              style: GoogleFonts.firaCode(
                                fontSize: 10,
                                color: AppTheme.primaryCyan,
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.secondaryTeal),
                            onPressed: () => _copyChunk(context, chunk.text, chunk.chunkId),
                            tooltip: 'Copy Chunk',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        chunk.text.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFFE2E8F0),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
