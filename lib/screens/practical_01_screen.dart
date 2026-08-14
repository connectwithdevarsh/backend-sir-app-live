import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/practical_result.dart';
import '../services/practical_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_background_painter.dart';
import '../widgets/practical_completion_button.dart';

/// Practical01Screen implements a live, real interactive Generative AI practical.
/// Connects to Python FastAPI backend & Google Gemini API.
class Practical01Screen extends StatefulWidget {
  const Practical01Screen({super.key});

  @override
  State<Practical01Screen> createState() => _Practical01ScreenState();
}

class _Practical01ScreenState extends State<Practical01Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;
  late TextEditingController _promptController;

  static const String _defaultPrompt =
      'Explain the basics of Artificial Intelligence.\n'
      'Include:\n'
      '1. Definition of AI\n'
      '2. How AI works at a basic level\n'
      '3. Difference between AI, Machine Learning and Deep Learning\n'
      '4. Three real-world applications of AI\n'
      '5. One simple example for a beginner.';

  bool _isLoading = false;
  PracticalResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _promptController = TextEditingController(text: _defaultPrompt);
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _runPractical() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showSnackBar('Please enter a valid prompt before running.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    final result = await PracticalApiService.runPractical1(prompt);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _result = result;
          _errorMessage = null;
        } else {
          _errorMessage = result.output;
          _result = null;
        }
      });
    }
  }

  void _resetPractical() {
    setState(() {
      _promptController.text = _defaultPrompt;
      _isLoading = false;
      _result = null;
      _errorMessage = null;
    });
    _showSnackBar('Practical reset to initial default state.');
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('AI response copied to clipboard.');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : AppTheme.primaryCyan.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // 1. Ambient Background Neural Glow
          AnimatedBuilder(
            animation: _bgPulseController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: AIBackgroundPainter(
                  animationValue: _bgPulseController.value,
                ),
              );
            },
          ),

          // 2. Main Scrollable Dashboard Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // APP BAR
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppTheme.primaryCyan,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'PRACTICAL 01',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            const PracticalCompletionButton(
                              practicalId: 1,
                              isCompact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // PRACTICAL TITLE CARD
                        Text(
                          'Explain the Basics of AI using a Generative AI Tool',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // AIM CARD
                        _buildSectionCard(
                          title: 'AIM',
                          icon: Icons.flag_rounded,
                          accentColor: AppTheme.primaryCyan,
                          content:
                              'To understand and explain the basic concepts of Artificial Intelligence using a Generative AI tool.',
                        ),
                        const SizedBox(height: 16),

                        // OBJECTIVE CARD
                        _buildSectionCard(
                          title: 'OBJECTIVE',
                          icon: Icons.track_changes_rounded,
                          accentColor: AppTheme.academicGold,
                          content:
                              'Use a Generative AI model to obtain an explanation of Artificial Intelligence and understand its basic concepts and applications.',
                        ),
                        const SizedBox(height: 16),

                        // INPUT PROMPT EDITOR
                        _buildPromptEditorSection(),
                        const SizedBox(height: 20),

                        // RUN & RESET BUTTONS
                        _buildActionButtons(),
                        const SizedBox(height: 24),

                        // ERROR DISPLAY STATE
                        if (_errorMessage != null) _buildErrorCard(),

                        // ACTUAL AI OUTPUT CONSOLE
                        if (_isLoading || _result != null)
                          _buildOutputConsoleSection(),

                        // RESULT STATEMENT SECTION
                        if (_result != null && _result!.success)
                          _buildResultStatementCard(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptEditorSection() {
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
                    Icons.edit_note_rounded,
                    size: 18,
                    color: AppTheme.primaryCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INPUT PROMPT (EDITABLE)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                'Student Input',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 7,
            minLines: 4,
            enabled: !_isLoading,
            style: GoogleFonts.firaCode(
              fontSize: 12.5,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              hintText: 'Enter your AI prompt here...',
              hintStyle: GoogleFonts.firaCode(
                color: AppTheme.textMuted,
                fontSize: 12,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        // RUN PRACTICAL BUTTON
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _runPractical,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppTheme.primaryCyan.withValues(alpha: 0.4),
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'GENERATING RESPONSE...',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        'RUN PRACTICAL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // RESET BUTTON
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _resetPractical,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'RESET',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF451A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFCA5A5),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXECUTION ERROR',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFCA5A5),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputConsoleSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isLoading
              ? AppTheme.primaryCyan.withValues(alpha: 0.4)
              : AppTheme.secondaryTeal.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                    'ACTUAL AI OUTPUT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (_result != null)
                TextButton.icon(
                  onPressed: () => _copyToClipboard(_result!.output),
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: AppTheme.primaryCyan,
                  ),
                  label: Text(
                    'COPY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryCyan,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Waiting for AI response...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_result != null) ...[
            // REAL GENERATED TEXT OUTPUT
            SelectableText(
              _result!.output,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 16),

            // EXECUTION METADATA DETAILS
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildMetaBadge(
                  icon: Icons.check_circle_rounded,
                  label: 'Execution Completed',
                  color: const Color(0xFF10B981),
                ),
                _buildMetaBadge(
                  icon: Icons.memory_rounded,
                  label: 'Model: ${_result!.model}',
                  color: AppTheme.primaryCyan,
                ),
                _buildMetaBadge(
                  icon: Icons.timer_rounded,
                  label: 'Latency: ${_result!.executionTimeMs} ms',
                  color: AppTheme.academicGold,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildResultStatementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.academicGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.academicGold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.task_alt_rounded,
                size: 18,
                color: AppTheme.academicGold,
              ),
              const SizedBox(width: 8),
              Text(
                'RESULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.academicGold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Successfully generated an AI-based explanation of Artificial Intelligence using a Generative AI tool.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
