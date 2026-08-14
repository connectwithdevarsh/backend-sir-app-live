import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rag_response.dart';
import '../theme/app_theme.dart';

/// SourceCitationCard displays source references and page citations for RAG outputs.
class SourceCitationCard extends StatelessWidget {
  final List<SourceCitation> sources;

  const SourceCitationCard({
    super.key,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmarks_rounded, color: AppTheme.primaryCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'DOCUMENT SOURCE CITATIONS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: sources.map((src) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_rounded, size: 14, color: AppTheme.primaryCyan),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File: ${src.filename} • Page ${src.page} • Chunk: ${src.chunkId}',
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (src.score != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Score: ${src.score!.toStringAsFixed(4)}',
                        style: GoogleFonts.firaCode(fontSize: 10, color: AppTheme.secondaryTeal),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
