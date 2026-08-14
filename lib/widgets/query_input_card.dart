import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// QueryInputCard provides a styled multiline input area with
/// category-aware presets for Factual, Logical, and Ambiguous queries.
class QueryInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String category;
  final ValueChanged<String>? onPresetSelected;
  final bool isEnabled;

  const QueryInputCard({
    super.key,
    required this.controller,
    required this.category,
    this.onPresetSelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    String helperText;
    List<Map<String, String>> presets;

    switch (category.toLowerCase()) {
      case 'logical':
        accentColor = AppTheme.accentPurple;
        helperText = 'Logic/reasoning queries test if the LLM applies deductive or conditional rules accurately.';
        presets = [
          {
            'label': 'Syllogism (Mammals & Dogs)',
            'query': 'If all mammals are animals and all dogs are mammals, are all dogs animals? Explain briefly.',
            'ref': 'Yes, under the stated premises.',
          },
          {
            'label': 'Transitive Logic (A > B > C)',
            'query': 'If Alice is taller than Bob, and Bob is taller than Charlie, is Charlie necessarily shorter than Alice? Explain.',
            'ref': 'Yes, Charlie is shorter than Alice.',
          },
          {
            'label': 'Conditional Truth (Rain & Wet)',
            'query': 'If it rains, the ground is wet. The ground is wet. Did it necessarily rain? Explain briefly.',
            'ref': 'No, the ground could be wet for other reasons (affirming the consequent).',
          },
        ];
        break;

      case 'ambiguous':
        accentColor = const Color(0xFFF59E0B);
        helperText = 'Ambiguous queries have multiple interpretations or lack crucial context.';
        presets = [
          {
            'label': 'Java (Language vs Island)',
            'query': 'Tell me about Java.',
            'ref': 'Ambiguous: Java can refer to the programming language, the Indonesian island, or coffee.',
          },
          {
            'label': 'Apple (Tech vs Fruit)',
            'query': 'What is the history of Apple?',
            'ref': 'Ambiguous: Could refer to Apple Inc. or the domestic apple tree species.',
          },
          {
            'label': 'Bank (Financial vs River)',
            'query': 'How do I reach the bank?',
            'ref': 'Ambiguous: Lacks context on financial institution vs river bank.',
          },
        ];
        break;

      case 'factual':
      default:
        accentColor = AppTheme.primaryCyan;
        helperText = 'Factual queries have objective, verifiable answers verifiable through knowledge bases.';
        presets = [
          {
            'label': 'Capital of France',
            'query': 'What is the capital of France?',
            'ref': 'Paris',
          },
          {
            'label': 'Speed of Light',
            'query': 'What is the exact speed of light in vacuum in meters per second?',
            'ref': '299,792,458 m/s',
          },
          {
            'label': 'First Moon Landing',
            'query': 'In which year did humans first land on the Moon, and who was the first person to step on it?',
            'ref': '1969, Neil Armstrong',
          },
        ];
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ENTER QUERY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            helperText,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: BorderSide(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                    label: Text(
                      preset['label']!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    onPressed: isEnabled
                        ? () {
                            controller.text = preset['query']!;
                            if (onPresetSelected != null) {
                              onPresetSelected!(preset['ref'] ?? '');
                            }
                          }
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Editable Query TextField
          TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: 4,
            minLines: 3,
            style: GoogleFonts.firaCode(
              fontSize: 13.5,
              color: Colors.white,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Enter a ${category.toLowerCase()} question or prompt...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white24,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0F1D),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: accentColor,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
