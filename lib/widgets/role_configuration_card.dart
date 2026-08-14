import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// RoleConfigurationCard provides role persona, audience, tone, and constraint
/// editors with preset chips for Role-Based prompting.
class RoleConfigurationCard extends StatelessWidget {
  final TextEditingController roleController;
  final TextEditingController audienceController;
  final TextEditingController toneController;
  final TextEditingController constraintsController;
  final bool isEnabled;

  const RoleConfigurationCard({
    super.key,
    required this.roleController,
    required this.audienceController,
    required this.toneController,
    required this.constraintsController,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final presets = [
      {
        'label': 'AI Professor',
        'role': 'You are an experienced Artificial Intelligence professor explaining concepts to Diploma IT students.',
        'audience': 'Diploma IT 5th Semester students',
        'tone': 'Academic, clear, and encouraging',
        'constraints': 'Provide high-level structure, 2 real-world analogies, and keep it under 300 words.',
      },
      {
        'label': 'Cybersecurity Instructor',
        'role': 'You are a certified ethical hacker and cybersecurity instructor.',
        'audience': 'Junior network administrators & engineering students',
        'tone': 'Practical, security-conscious, and direct',
        'constraints': 'Highlight preventive defense tactics and common vulnerabilities.',
      },
      {
        'label': 'Senior Software Architect',
        'role': 'You are a principal software architect with 15+ years of industry experience.',
        'audience': 'Apprentice developers',
        'tone': 'Professional, industry-aligned, and pragmatic',
        'constraints': 'Focus on scalability, clean code, and production reliability.',
      },
    ];

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
                  Icons.person_pin_rounded,
                  color: AppTheme.accentPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ROLE & PERSONA CONFIGURATION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
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
                  'ROLE-BASED',
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
            'Role-based prompting explicitly establishes a perspective, expertise domain, and communicative stance:',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),

          const SizedBox(height: 10),

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
                      color: AppTheme.accentPurple.withValues(alpha: 0.35),
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
                            roleController.text = preset['role']!;
                            audienceController.text = preset['audience']!;
                            toneController.text = preset['tone']!;
                            constraintsController.text = preset['constraints']!;
                          }
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // 1. Role Persona TextField
          _buildField(
            label: 'System Persona / Role Definition:',
            controller: roleController,
            hint: 'e.g. You are an experienced AI teacher explaining to Diploma IT students...',
            maxLines: 2,
          ),

          const SizedBox(height: 10),

          // 2. Audience & Tone Row
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Target Audience:',
                  controller: audienceController,
                  hint: 'e.g. Diploma IT students',
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField(
                  label: 'Tone & Style:',
                  controller: toneController,
                  hint: 'e.g. Educational & simple',
                  maxLines: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Constraints TextField
          _buildField(
            label: 'Constraints & Formatting:',
            controller: constraintsController,
            hint: 'e.g. Use bullet points, keep concise, provide examples...',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isEnabled,
          maxLines: maxLines,
          style: GoogleFonts.firaCode(
            fontSize: 12.5,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(color: AppTheme.accentPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
