import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rag_document.dart';
import '../theme/app_theme.dart';

/// DocumentStatusCard renders document details and chunk indexing state.
class DocumentStatusCard extends StatelessWidget {
  final RagDocument document;
  final VoidCallback onRemove;

  const DocumentStatusCard({
    super.key,
    required this.document,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReady = document.status == 'ready';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isReady
              ? AppTheme.secondaryTeal.withValues(alpha: 0.4)
              : AppTheme.primaryCyan.withValues(alpha: 0.4),
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
                  color: (isReady ? AppTheme.secondaryTeal : AppTheme.primaryCyan)
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReady ? Icons.check_circle_rounded : Icons.sync_rounded,
                  color: isReady ? AppTheme.secondaryTeal : AppTheme.primaryCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.filename,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${document.fileType.toUpperCase()} • ${document.formattedFileSize} • ${document.chunkCount} Text Chunks',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                onPressed: onRemove,
                tooltip: 'Remove Document',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isReady ? AppTheme.secondaryTeal : AppTheme.primaryCyan)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isReady
                  ? '✓ DOCUMENT INDEXED & READY FOR QUESTION ANSWERING'
                  : '⟳ PROCESSING DOCUMENT & BUILDING VECTOR INDEX...',
              style: GoogleFonts.firaCode(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isReady ? AppTheme.secondaryTeal : AppTheme.primaryCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
