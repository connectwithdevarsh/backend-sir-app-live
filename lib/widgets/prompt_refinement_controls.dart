import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// PromptRefinementControls provides interactive refinement parameters
/// (Audience, Tone, Format, Length, Constraints) to help students structure refined prompts.
class PromptRefinementControls extends StatefulWidget {
  final String basicPrompt;
  final ValueChanged<String> onRefinedPromptGenerated;
  final bool isEnabled;

  const PromptRefinementControls({
    super.key,
    required this.basicPrompt,
    required this.onRefinedPromptGenerated,
    this.isEnabled = true,
  });

  @override
  State<PromptRefinementControls> createState() => _PromptRefinementControlsState();
}

class _PromptRefinementControlsState extends State<PromptRefinementControls> {
  String _selectedAudience = 'Teacher';
  String _selectedTone = 'Formal';
  String _selectedFormat = 'Structured';
  String _selectedLength = 'Medium';
  final TextEditingController _contextController = TextEditingController(
    text: 'Include clear reasons, key dates/points, and professional closing.',
  );

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  void _generateRefinedPrompt() {
    final base = widget.basicPrompt.trim().isNotEmpty
        ? widget.basicPrompt.trim()
        : 'Please perform the specified task';

    final buffer = StringBuffer();
    buffer.writeln('$base\n');
    buffer.writeln('Please follow these specific instructions:');
    buffer.writeln('• Target Audience: $_selectedAudience');
    buffer.writeln('• Tone: $_selectedTone and respectful');
    buffer.writeln('• Output Format: $_selectedFormat');
    buffer.writeln('• Desired Length: $_selectedLength');

    final extraContext = _contextController.text.trim();
    if (extraContext.isNotEmpty) {
      buffer.writeln('• Additional Requirements: $extraContext');
    }

    buffer.writeln('Ensure the output is clean, precise, and immediately usable without unnecessary conversational filler.');

    widget.onRefinedPromptGenerated(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final audienceOptions = ['Teacher', 'Student', 'General', 'Technical Expert'];
    final toneOptions = ['Formal', 'Professional', 'Friendly', 'Academic', 'Concise'];
    final formatOptions = ['Structured', 'Bullet Points', 'Step-by-Step', 'Paragraph'];
    final lengthOptions = ['Short', 'Medium', 'Detailed'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_fix_high_rounded,
                  color: AppTheme.accentPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'PROMPT REFINEMENT ASSISTANT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'PARAMETERS',
                  style: GoogleFonts.firaCode(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Select engineering dimensions to inject context, constraints, and structure into your basic prompt:',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),

          const SizedBox(height: 14),

          // 1. Audience Selector
          _buildParamSection(
            title: 'Target Audience:',
            options: audienceOptions,
            selectedValue: _selectedAudience,
            onSelected: (val) => setState(() => _selectedAudience = val),
          ),

          const SizedBox(height: 10),

          // 2. Tone Selector
          _buildParamSection(
            title: 'Tone & Persona:',
            options: toneOptions,
            selectedValue: _selectedTone,
            onSelected: (val) => setState(() => _selectedTone = val),
          ),

          const SizedBox(height: 10),

          // 3. Format Selector
          _buildParamSection(
            title: 'Output Format:',
            options: formatOptions,
            selectedValue: _selectedFormat,
            onSelected: (val) => setState(() => _selectedFormat = val),
          ),

          const SizedBox(height: 10),

          // 4. Length Selector
          _buildParamSection(
            title: 'Desired Length:',
            options: lengthOptions,
            selectedValue: _selectedLength,
            onSelected: (val) => setState(() => _selectedLength = val),
          ),

          const SizedBox(height: 12),

          // 5. Additional Context TextField
          Text(
            'Additional Context / Constraints:',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _contextController,
            enabled: widget.isEnabled,
            maxLines: 2,
            minLines: 1,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Include subject line, date, reasons...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF0A0F1D),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.accentPurple),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.isEnabled ? _generateRefinedPrompt : null,
              icon: const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.accentPurple),
              label: Text(
                'APPLY REFINEMENT PARAMETERS TO PROMPT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.12),
                side: BorderSide(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
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

  Widget _buildParamSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              final bool isSelected = selectedValue == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    opt,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.accentPurple.withValues(alpha: 0.3),
                  backgroundColor: const Color(0xFF0F172A),
                  side: BorderSide(
                    color: isSelected ? AppTheme.accentPurple : Colors.white12,
                  ),
                  onSelected: widget.isEnabled ? (_) => onSelected(opt) : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
