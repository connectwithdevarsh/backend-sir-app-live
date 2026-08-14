import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_example.dart';
import '../theme/app_theme.dart';

/// FewShotExamples manages the dynamic, editable list of Input/Output demonstration pairs.
class FewShotExamples extends StatelessWidget {
  final List<PromptExample> examples;
  final VoidCallback onAddExample;
  final ValueChanged<int> onRemoveExample;
  final bool isEnabled;

  const FewShotExamples({
    super.key,
    required this.examples,
    required this.onAddExample,
    required this.onRemoveExample,
    this.isEnabled = true,
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
          color: AppTheme.secondaryTeal.withValues(alpha: 0.35),
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
                    Icons.format_list_bulleted_rounded,
                    size: 18,
                    color: AppTheme.secondaryTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FEW-SHOT DEMONSTRATION EXAMPLES',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTeal,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              if (isEnabled && examples.length < 5)
                TextButton.icon(
                  onPressed: onAddExample,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      size: 14, color: AppTheme.secondaryTeal),
                  label: Text(
                    '+ Add',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTeal,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Provide input-output pairs to guide the model toward desired format and style.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // LIST OF EXAMPLES
          ...examples.asMap().entries.map((entry) {
            final int index = entry.key;
            final PromptExample eg = entry.value;
            return _buildExampleItem(index, eg);
          }),
        ],
      ),
    );
  }

  Widget _buildExampleItem(int index, PromptExample eg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXAMPLE ${index + 1}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
              if (isEnabled && examples.length > 1)
                InkWell(
                  onTap: () => onRemoveExample(index),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // INPUT FIELD
          TextFormField(
            initialValue: eg.input,
            enabled: isEnabled,
            onChanged: (val) => eg.input = val,
            style: GoogleFonts.firaCode(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Input',
              labelStyle: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
              filled: true,
              fillColor: const Color(0xFF0B1120),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.secondaryTeal),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // OUTPUT FIELD
          TextFormField(
            initialValue: eg.output,
            enabled: isEnabled,
            onChanged: (val) => eg.output = val,
            style: GoogleFonts.firaCode(
              fontSize: 12,
              color: const Color(0xFF10B981),
            ),
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Expected Output',
              labelStyle: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
              filled: true,
              fillColor: const Color(0xFF0B1120),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
