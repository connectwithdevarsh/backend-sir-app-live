import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// TaskInputCard provides a multiline editor for students to specify the core task / query.
class TaskInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final VoidCallback onClear;

  const TaskInputCard({
    super.key,
    required this.controller,
    required this.isEnabled,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.terminal_rounded,
                    size: 18,
                    color: AppTheme.primaryCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TARGET TASK / QUERY (EDITABLE)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (isEnabled)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 2,
            enabled: isEnabled,
            style: GoogleFonts.firaCode(
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              hintText: 'Enter task instruction or sentence to analyze...',
              hintStyle: GoogleFonts.firaCode(
                color: AppTheme.textMuted,
                fontSize: 12.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryCyan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
