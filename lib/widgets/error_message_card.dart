import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ErrorMessageCard renders a user-friendly error banner when an API or network request fails.
class ErrorMessageCard extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorMessageCard({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection / API Error',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  errorMessage,
                  style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: onRetry,
              tooltip: 'Retry Connection',
            ),
          ],
        ],
      ),
    );
  }
}
