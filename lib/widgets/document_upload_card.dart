import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// DocumentUploadCard builds the upload container supporting document selection (.pdf / .txt)
/// and quick-loading of the built-in sample AI notes test document.
class DocumentUploadCard extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onUploadPressed;
  final VoidCallback onLoadSamplePressed;

  const DocumentUploadCard({
    super.key,
    required this.isProcessing,
    required this.onUploadPressed,
    required this.onLoadSamplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_rounded, color: AppTheme.primaryCyan, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'UPLOAD STUDY DOCUMENT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Supported Formats: PDF (.pdf) or Plain Text (.txt) • Max: 10 MB',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : onUploadPressed,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: Text(
                    '📄 UPLOAD FILE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isProcessing ? null : onLoadSamplePressed,
                  icon: const Icon(Icons.note_add_rounded, size: 18),
                  label: Text(
                    '⚡ LOAD SAMPLE AI NOTES',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryTeal,
                    side: const BorderSide(color: AppTheme.secondaryTeal),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
