import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/nlp_result.dart';
import '../services/nlp_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_background_painter.dart';
import '../widgets/practical_completion_button.dart';
import '../widgets/nlp_input_card.dart';
import '../widgets/nlp_result_card.dart';
import '../widgets/nlp_task_selector.dart';

/// Practical02Screen implements a real, live-executing NLP practical
/// performing genuine local Sentiment Analysis & Text Classification via Python NLP service.
class Practical02Screen extends StatefulWidget {
  const Practical02Screen({super.key});

  @override
  State<Practical02Screen> createState() => _Practical02ScreenState();
}

class _Practical02ScreenState extends State<Practical02Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;
  late TextEditingController _textController;

  static const String _defaultExample =
      'I really enjoyed this course. The practical sessions were useful and easy to understand.';

  String _selectedTask = 'sentiment'; // 'sentiment' or 'classification'
  bool _isLoading = false;
  NlpResult? _result;
  String? _errorMessage;

  bool _isTheoryExpanded = false;
  bool _isProcedureExpanded = false;

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _textController = TextEditingController(text: _defaultExample);
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _runNlpAnalysis() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Please enter some text for analysis.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    final res = await NlpApiService.analyzeText(
      text: text,
      task: _selectedTask,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success) {
          _result = res;
          _errorMessage = null;
        } else {
          _errorMessage = res.errorMessage ?? 'NLP processing failed.';
          _result = null;
        }
      });
    }
  }

  void _resetPractical() {
    setState(() {
      _textController.text = _defaultExample;
      _selectedTask = 'sentiment';
      _isLoading = false;
      _result = null;
      _errorMessage = null;
    });
    _showSnackBar('Practical reset to initial state.');
  }

  void _copyResult() {
    if (_result == null) return;
    final text = 'Task: ${_result!.task.toUpperCase()}\n'
        'Input: "${_textController.text.trim()}"\n'
        'Result: ${_result!.label}\n'
        'Analysis: ${_result!.explanation}\n'
        'Latency: ${_result!.executionTimeMs} ms';
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Result copied to clipboard.');
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

          // 2. Main Scrollable Interface
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
                              'PRACTICAL 02',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            const PracticalCompletionButton(
                              practicalId: 2,
                              isCompact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // PRACTICAL TITLE
                        Text(
                          'Basic NLP Tasks: Sentiment Analysis & Text Classification',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // OFFICIAL OUTCOME CARD
                        _buildOutcomeCard(),
                        const SizedBox(height: 14),

                        // AIM CARD
                        _buildSectionCard(
                          title: 'AIM',
                          icon: Icons.flag_rounded,
                          accentColor: AppTheme.primaryCyan,
                          content:
                              'To perform basic NLP-based tasks such as sentiment analysis and text classification using AI tools or Python libraries.',
                        ),
                        const SizedBox(height: 14),

                        // OBJECTIVE CARD
                        _buildSectionCard(
                          title: 'OBJECTIVE',
                          icon: Icons.track_changes_rounded,
                          accentColor: AppTheme.academicGold,
                          content:
                              'To understand how Natural Language Processing can be used to analyze human language and classify text into meaningful categories.',
                        ),
                        const SizedBox(height: 14),

                        // THEORY ACCORDION
                        _buildTheoryAccordion(),
                        const SizedBox(height: 14),

                        // PROCEDURE ACCORDION
                        _buildProcedureAccordion(),
                        const SizedBox(height: 20),

                        // TASK SELECTION SEGMENT
                        Text(
                          'SELECT NLP TASK',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryCyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        NlpTaskSelector(
                          selectedTask: _selectedTask,
                          isEnabled: !_isLoading,
                          onTaskChanged: (newTask) {
                            setState(() {
                              _selectedTask = newTask;
                              _result = null;
                              _errorMessage = null;
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        // INPUT TEXT CARD
                        NlpInputCard(
                          controller: _textController,
                          isEnabled: !_isLoading,
                          onClear: () => _textController.clear(),
                        ),
                        const SizedBox(height: 20),

                        // RUN & RESET BUTTONS
                        _buildActionButtons(),
                        const SizedBox(height: 24),

                        // ERROR DISPLAY
                        if (_errorMessage != null) _buildErrorCard(),

                        // LOADING STATE
                        if (_isLoading) _buildLoadingCard(),

                        // RESULT CARD
                        if (_result != null && !_isLoading)
                          NlpResultCard(
                            result: _result!,
                            inputText: _textController.text.trim(),
                            onCopy: _copyResult,
                          ),

                        // CONCLUSION / RESULT STATEMENT
                        if (_result != null && _result!.success && !_isLoading)
                          _buildConclusionCard(),

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

  Widget _buildOutcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 16,
                color: AppTheme.primaryCyan,
              ),
              const SizedBox(width: 8),
              Text(
                'OFFICIAL GTU OUTCOME (UNIT 1 • 2 HOURS)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Perform basic NLP-based tasks such as sentiment analysis and text classification using AI tools or Python libraries.',
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

  Widget _buildTheoryAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isTheoryExpanded,
          onExpansionChanged: (v) => setState(() => _isTheoryExpanded = v),
          leading: const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.secondaryTeal,
            size: 18,
          ),
          title: Text(
            'THEORY & CONCEPTS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTeal,
              letterSpacing: 1.0,
            ),
          ),
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTheoryItem(
                    '1. What is NLP?',
                    'Natural Language Processing (NLP) is a branch of Artificial Intelligence that enables computers to understand, interpret, and generate human language.',
                  ),
                  const SizedBox(height: 10),
                  _buildTheoryItem(
                    '2. What is Sentiment Analysis?',
                    'Sentiment Analysis determines the emotional tone behind a body of text (Positive, Negative, or Neutral) by evaluating word polarity and semantic intensity.',
                  ),
                  const SizedBox(height: 10),
                  _buildTheoryItem(
                    '3. What is Text Classification?',
                    'Text Classification organizes unstructured text into predefined categories (e.g. Technology, Education, Healthcare) using probabilistic feature classifiers.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isProcedureExpanded,
          onExpansionChanged: (v) => setState(() => _isProcedureExpanded = v),
          leading: const Icon(
            Icons.format_list_numbered_rounded,
            color: AppTheme.academicGold,
            size: 18,
          ),
          title: Text(
            'LABORATORY PROCEDURE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.academicGold,
              letterSpacing: 1.0,
            ),
          ),
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProcedureStep('Step 1', 'Enter custom text or a sample sentence in the input field.'),
                  _buildProcedureStep('Step 2', 'Select the target task (Sentiment Analysis or Text Classification).'),
                  _buildProcedureStep('Step 3', 'Click ▶ RUN NLP ANALYSIS to initiate backend processing.'),
                  _buildProcedureStep('Step 4', 'The Python NLP engine extracts word features and computes polarity.'),
                  _buildProcedureStep('Step 5', 'Observe the predicted label, confidence percentage, and latency.'),
                  _buildProcedureStep('Step 6', 'Click COPY to record the output in your laboratory workbook.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTheoryItem(String heading, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProcedureStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.academicGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              step,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.academicGold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
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
        // RUN BUTTON
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _runNlpAnalysis,
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
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 22),
            label: Text(
              _isLoading ? 'ANALYZING TEXT...' : 'RUN NLP ANALYSIS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
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

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryCyan,
            strokeWidth: 3,
          ),
          const SizedBox(height: 14),
          Text(
            'Executing NLP Model...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Analyzing semantic polarity & feature vectors on local engine',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
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
                  'NLP EXECUTION ERROR',
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

  Widget _buildConclusionCard() {
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
                'RESULT / CONCLUSION',
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
            'The selected NLP task was successfully performed on the entered text using the Python NLP processing engine.',
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
