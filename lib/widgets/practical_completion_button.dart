import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_storage_service.dart';
import '../theme/app_theme.dart';

/// PracticalCompletionButton renders a persistent completion toggle button for a practical.
class PracticalCompletionButton extends StatelessWidget {
  final int practicalId;
  final bool isCompact;

  const PracticalCompletionButton({
    super.key,
    required this.practicalId,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ProgressStorageService.progressChangeNotifier,
      builder: (context, val, child) {
        final isCompleted = ProgressStorageService.isPracticalCompletedSync(practicalId);
        final timestamp = ProgressStorageService.getCompletionTimestampSync(practicalId);

        String tooltipDate = '';
        if (timestamp != null) {
          tooltipDate = 'Completed: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
        }

        if (isCompact) {
          return InkWell(
            onTap: () async {
              await ProgressStorageService.togglePracticalCompletion(practicalId);
              final isNowDone = ProgressStorageService.isPracticalCompletedSync(practicalId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isNowDone
                        ? '✓ Practical $practicalId completed'
                        : 'Practical $practicalId marked as incomplete'),
                    backgroundColor: isNowDone ? AppTheme.secondaryTeal : Colors.grey[800],
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Tooltip(
              message: tooltipDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.secondaryTeal.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.secondaryTeal
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 14,
                      color: isCompleted ? AppTheme.secondaryTeal : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCompleted ? '✓ COMPLETED' : 'MARK AS READ',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppTheme.secondaryTeal : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: () async {
            await ProgressStorageService.togglePracticalCompletion(practicalId);
            final isNowDone = ProgressStorageService.isPracticalCompletedSync(practicalId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isNowDone
                      ? '✓ Practical $practicalId completed'
                      : 'Practical $practicalId marked as incomplete'),
                  backgroundColor: isNowDone ? AppTheme.secondaryTeal : Colors.grey[800],
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            side: BorderSide(
              color: isCompleted
                  ? AppTheme.secondaryTeal
                  : Colors.white.withValues(alpha: 0.2),
            ),
            backgroundColor: isCompleted
                ? AppTheme.secondaryTeal.withValues(alpha: 0.15)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.check_box_outline_blank_rounded,
            size: 18,
            color: isCompleted ? AppTheme.secondaryTeal : AppTheme.textSecondary,
          ),
          label: Text(
            isCompleted ? '✓ COMPLETED' : 'MARK AS READ',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppTheme.secondaryTeal : AppTheme.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
