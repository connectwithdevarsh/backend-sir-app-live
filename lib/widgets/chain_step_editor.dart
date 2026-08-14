import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chain_step.dart';
import '../theme/app_theme.dart';

/// ChainStepEditor builds the interactive editor card for configuring
/// 2 to 6 prompt chain steps with variable insertion tags.
class ChainStepEditor extends StatelessWidget {
  final List<ChainStep> steps;
  final bool isEnabled;
  final VoidCallback onAddStep;
  final ValueChanged<int> onRemoveStep;

  const ChainStepEditor({
    super.key,
    required this.steps,
    required this.isEnabled,
    required this.onAddStep,
    required this.onRemoveStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.link_rounded, color: AppTheme.accentViolet, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'PROMPT CHAIN CONFIGURATION',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentViolet,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '${steps.length} of 6 Steps',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Each step prompt runs sequentially. Use variables to pass data from previous steps.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),

          // Render step cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 1, height: 12, color: AppTheme.accentViolet.withValues(alpha: 0.4)),
                    Icon(Icons.arrow_downward_rounded, size: 12, color: AppTheme.accentViolet),
                    Container(width: 1, height: 12, color: AppTheme.accentViolet.withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final step = steps[index];
              return _buildSingleStepCard(context, index, step);
            },
          ),

          const SizedBox(height: 16),

          // Add step button
          if (steps.length < 6)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isEnabled ? onAddStep : null,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  '+ ADD CHAIN STEP (${steps.length}/6)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentViolet,
                  side: BorderSide(color: AppTheme.accentViolet.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleStepCard(BuildContext context, int index, ChainStep step) {
    final stepNum = index + 1;
    final TextEditingController nameCtrl = TextEditingController(text: step.name);
    final TextEditingController promptCtrl = TextEditingController(text: step.prompt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentViolet.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'STEP $stepNum',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentViolet,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: nameCtrl,
                  enabled: isEnabled,
                  onChanged: (val) => step.name = val,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Step Name...',
                  ),
                ),
              ),
              if (steps.length > 2)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  onPressed: isEnabled ? () => onRemoveStep(index) : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Prompt Template Input
          TextField(
            controller: promptCtrl,
            enabled: isEnabled,
            maxLines: 2,
            onChanged: (val) => step.prompt = val,
            style: GoogleFonts.firaCode(fontSize: 11.5, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter step prompt template...',
              hintStyle: GoogleFonts.firaCode(fontSize: 11.5, color: AppTheme.textMuted),
              filled: true,
              fillColor: const Color(0xFF070B15),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Helper Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildVariableTag(promptCtrl, step, '{{original_task}}'),
              _buildVariableTag(promptCtrl, step, '{{previous_output}}'),
              _buildVariableTag(promptCtrl, step, '{{step_number}}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariableTag(TextEditingController ctrl, ChainStep step, String tag) {
    return InkWell(
      onTap: isEnabled
          ? () {
              final text = ctrl.text;
              final selection = ctrl.selection;
              final newText = text.replaceRange(
                selection.start >= 0 ? selection.start : text.length,
                selection.end >= 0 ? selection.end : text.length,
                tag,
              );
              ctrl.text = newText;
              step.prompt = newText;
            }
          : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.3)),
        ),
        child: Text(
          '+ $tag',
          style: GoogleFonts.firaCode(
            fontSize: 9.5,
            color: AppTheme.accentViolet,
          ),
        ),
      ),
    );
  }
}
