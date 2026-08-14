import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// OptimizationControls builds task-specific optimization parameters for
/// Summarization, Blog Generation, or Code Generation tasks.
class OptimizationControls extends StatelessWidget {
  final String taskType; // "summarization", "blog", "code"
  final bool isEnabled;

  // Summarization state
  final String summaryLength;
  final String summaryAudience;
  final String summaryFormat;
  final String summaryFocus;

  // Blog state
  final String blogAudience;
  final String blogTone;
  final String blogLength;
  final TextEditingController keywordsController;

  // Code state
  final String codeLanguage;
  final bool includeComments;
  final bool includeValidation;
  final bool useFunction;
  final bool explainCode;
  final bool includeSampleIO;

  // Callbacks
  final ValueChanged<String>? onSummaryLengthChanged;
  final ValueChanged<String>? onSummaryAudienceChanged;
  final ValueChanged<String>? onSummaryFormatChanged;
  final ValueChanged<String>? onSummaryFocusChanged;

  final ValueChanged<String>? onBlogAudienceChanged;
  final ValueChanged<String>? onBlogToneChanged;
  final ValueChanged<String>? onBlogLengthChanged;

  final ValueChanged<String>? onCodeLanguageChanged;
  final ValueChanged<bool>? onCommentsChanged;
  final ValueChanged<bool>? onValidationChanged;
  final ValueChanged<bool>? onFunctionChanged;
  final ValueChanged<bool>? onExplainChanged;
  final ValueChanged<bool>? onSampleIOChanged;

  const OptimizationControls({
    super.key,
    required this.taskType,
    required this.isEnabled,
    this.summaryLength = '100 words',
    this.summaryAudience = 'Diploma IT Student',
    this.summaryFormat = 'Bullet Points',
    this.summaryFocus = 'Main Ideas',
    this.blogAudience = 'Students',
    this.blogTone = 'Informative & Friendly',
    this.blogLength = 'Medium (~600 words)',
    required this.keywordsController,
    this.codeLanguage = 'Python',
    this.includeComments = true,
    this.includeValidation = true,
    this.useFunction = true,
    this.explainCode = true,
    this.includeSampleIO = true,
    this.onSummaryLengthChanged,
    this.onSummaryAudienceChanged,
    this.onSummaryFormatChanged,
    this.onSummaryFocusChanged,
    this.onBlogAudienceChanged,
    this.onBlogToneChanged,
    this.onBlogLengthChanged,
    this.onCodeLanguageChanged,
    this.onCommentsChanged,
    this.onValidationChanged,
    this.onFunctionChanged,
    this.onExplainChanged,
    this.onSampleIOChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppTheme.secondaryTeal, size: 18),
              const SizedBox(width: 8),
              Text(
                'PROMPT OPTIMIZATION CONTROLS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Configure domain constraints and context to structure the optimized prompt.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),

          if (taskType == 'summarization') _buildSummarizationControls(),
          if (taskType == 'blog') _buildBlogControls(),
          if (taskType == 'code') _buildCodeControls(),
        ],
      ),
    );
  }

  Widget _buildSummarizationControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Length',
                value: summaryLength,
                items: ['50 words', '100 words', '150 words', '200 words'],
                onChanged: onSummaryLengthChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdownField(
                label: 'Audience',
                value: summaryAudience,
                items: ['Diploma IT Student', 'General Audience', 'Professional'],
                onChanged: onSummaryAudienceChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Format',
                value: summaryFormat,
                items: ['Bullet Points', 'Paragraph', 'Key Points'],
                onChanged: onSummaryFormatChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdownField(
                label: 'Focus',
                value: summaryFocus,
                items: ['Main Ideas', 'Important Facts', 'Technical Terms'],
                onChanged: onSummaryFocusChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlogControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Audience',
                value: blogAudience,
                items: ['Students', 'General', 'Professionals'],
                onChanged: onBlogAudienceChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdownField(
                label: 'Tone',
                value: blogTone,
                items: ['Informative & Friendly', 'Professional', 'Conversational'],
                onChanged: onBlogToneChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDropdownField(
          label: 'Target Length',
          value: blogLength,
          items: ['Short (~400 words)', 'Medium (~600 words)', 'Long (~1000 words)'],
          onChanged: onBlogLengthChanged,
        ),
        const SizedBox(height: 10),
        Text('Keywords (comma separated):', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: keywordsController,
          enabled: isEnabled,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. ChatGPT, prompt engineering, diploma',
            hintStyle: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          label: 'Programming Language',
          value: codeLanguage,
          items: ['Python', 'JavaScript', 'Dart', 'Java', 'C++'],
          onChanged: onCodeLanguageChanged,
        ),
        const SizedBox(height: 12),
        Text('Requirements & Constraints:', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal)),
        const SizedBox(height: 6),
        _buildCheckboxTile('Include comments', includeComments, onCommentsChanged),
        _buildCheckboxTile('Include input validation', includeValidation, onValidationChanged),
        _buildCheckboxTile('Use modular function', useFunction, onFunctionChanged),
        _buildCheckboxTile('Explain code after program', explainCode, onExplainChanged),
        _buildCheckboxTile('Include sample input/output', includeSampleIO, onSampleIOChanged),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String>? onChanged,
  }) {
    final effectiveValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.secondaryTeal, size: 18),
              onChanged: isEnabled && onChanged != null ? (val) => val != null ? onChanged(val) : null : null,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool>? onChanged) {
    return InkWell(
      onTap: isEnabled && onChanged != null ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                activeColor: AppTheme.secondaryTeal,
                checkColor: Colors.black,
                onChanged: isEnabled && onChanged != null ? (val) => onChanged(val ?? false) : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
