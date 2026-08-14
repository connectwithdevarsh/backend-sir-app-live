import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_example.dart';
import '../models/prompt_result.dart';
import '../services/prompt_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_background_painter.dart';
import '../widgets/practical_completion_button.dart';
import '../widgets/few_shot_examples.dart';
import '../widgets/prompt_result_card.dart';
import '../widgets/prompting_method_selector.dart';
import '../widgets/task_input_card.dart';

/// Practical03Screen implements a real Prompt Engineering laboratory workbench
/// comparing Zero-Shot and Few-Shot prompting techniques against live Generative AI models.
class Practical03Screen extends StatefulWidget {
  const Practical03Screen({super.key});

  @override
  State<Practical03Screen> createState() => _Practical03ScreenState();
}

class _Practical03ScreenState extends State<Practical03Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;
  late TextEditingController _taskController;

  static const String _defaultTask =
      'Classify the sentiment of the following sentence:\nThe product quality is excellent.';

  String _selectedMethod = 'compare'; // 'zero_shot', 'few_shot', 'compare'
  bool _isLoading = false;
  String _loadingStatus = 'Running Prompting Engine...';

  PromptResult? _result;
  String? _errorMessage;

  bool _isTheoryExpanded = false;
  bool _isProcedureExpanded = false;

  late List<PromptExample> _fewShotExamples;

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _taskController = TextEditingController(text: _defaultTask);
    _initDefaultExamples();
  }

  void _initDefaultExamples() {
    _fewShotExamples = [
      PromptExample(input: 'I loved the movie.', output: 'Positive'),
      PromptExample(input: 'The service was terrible.', output: 'Negative'),
    ];
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _runPractical() async {
    final taskText = _taskController.text.trim();
    if (taskText.isEmpty) {
      _showSnackBar('Please enter a target task/query.', isError: true);
      return;
    }

    if (_selectedMethod != 'zero_shot' && _fewShotExamples.isEmpty) {
      _showSnackBar('Please add at least one Few-Shot example.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
      _loadingStatus = _selectedMethod == 'compare'
          ? 'Running Zero-Shot & Few-Shot Models...'
          : (_selectedMethod == 'zero_shot'
              ? 'Running Zero-Shot Model...'
              : 'Running Few-Shot Model...');
    });

    final res = await PromptApiService.runPrompting(
      task: taskText,
      method: _selectedMethod,
      examples: _fewShotExamples,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success) {
          _result = res;
          _errorMessage = null;
        } else {
          _errorMessage = res.error ?? 'Prompt execution failed.';
          _result = null;
        }
      });
    }
  }

  void _resetPractical() {
    setState(() {
      _taskController.text = _defaultTask;
      _selectedMethod = 'compare';
      _initDefaultExamples();
      _isLoading = false;
      _result = null;
      _errorMessage = null;
    });
    _showSnackBar('Practical reset to default task and examples.');
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
          // 1. Ambient Neural Glow Background
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

          // 2. Main Scrollable Workbench
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
                              'PRACTICAL 03',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            const PracticalCompletionButton(
                              practicalId: 3,
                              isCompact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // TITLE
                        Text(
                          'Zero-Shot & Few-Shot Prompting',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // OFFICIAL GTU OUTCOME CARD
                        _buildOutcomeCard(),
                        const SizedBox(height: 14),

                        // AIM CARD
                        _buildSectionCard(
                          title: 'AIM',
                          icon: Icons.flag_rounded,
                          accentColor: AppTheme.primaryCyan,
                          content:
                              'To create and test prompts using zero-shot and few-shot prompting techniques for a given task.',
                        ),
                        const SizedBox(height: 14),

                        // OBJECTIVE CARD
                        _buildSectionCard(
                          title: 'OBJECTIVE',
                          icon: Icons.track_changes_rounded,
                          accentColor: AppTheme.academicGold,
                          content:
                              'To understand how providing demonstration examples in a prompt can affect the format, consistency, and response generated by a Generative AI model.',
                        ),
                        const SizedBox(height: 14),

                        // THEORY ACCORDION
                        _buildTheoryAccordion(),
                        const SizedBox(height: 14),

                        // PROCEDURE ACCORDION
                        _buildProcedureAccordion(),
                        const SizedBox(height: 20),

                        // PROMPTING METHOD SELECTOR
                        Text(
                          'SELECT PROMPTING METHOD',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryCyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PromptingMethodSelector(
                          selectedMethod: _selectedMethod,
                          isEnabled: !_isLoading,
                          onMethodChanged: (method) {
                            setState(() {
                              _selectedMethod = method;
                              _result = null;
                              _errorMessage = null;
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        // TASK INPUT CARD
                        TaskInputCard(
                          controller: _taskController,
                          isEnabled: !_isLoading,
                          onClear: () => _taskController.clear(),
                        ),
                        const SizedBox(height: 18),

                        // FEW-SHOT EXAMPLES BUILDER (when method is few_shot or compare)
                        if (_selectedMethod != 'zero_shot') ...[
                          FewShotExamples(
                            examples: _fewShotExamples,
                            isEnabled: !_isLoading,
                            onAddExample: () {
                              if (_fewShotExamples.length < 5) {
                                setState(() {
                                  _fewShotExamples.add(
                                    PromptExample(input: '', output: ''),
                                  );
                                });
                              }
                            },
                            onRemoveExample: (idx) {
                              if (_fewShotExamples.length > 1) {
                                setState(() {
                                  _fewShotExamples.removeAt(idx);
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                        ],

                        // RUN & RESET ACTION BUTTONS
                        _buildActionButtons(),
                        const SizedBox(height: 24),

                        // ERROR DISPLAY
                        if (_errorMessage != null) _buildErrorCard(),

                        // LOADING SPINNER
                        if (_isLoading) _buildLoadingCard(),

                        // RESULTS SECTION
                        if (_result != null && !_isLoading) ...[
                          _buildResultsView(_result!),
                          const SizedBox(height: 16),
                          _buildConclusionCard(),
                        ],

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
                'OFFICIAL GTU OUTCOME (PROMPT ENGINEERING)',
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
            'Create and test prompts using zero-shot and few-shot prompting techniques for a given task.',
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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTheoryItem(
                    '1. Zero-Shot Prompting',
                    'Zero-shot prompting asks a Generative AI model to perform a task directly without providing task-specific demonstration examples. The model relies entirely on pre-trained knowledge.',
                  ),
                  const SizedBox(height: 10),
                  _buildTheoryItem(
                    '2. Few-Shot Prompting',
                    'Few-shot prompting includes a small set of input-output demonstration pairs within the prompt context. This in-context learning guides the model toward the desired format, style, and precision.',
                  ),
                  const SizedBox(height: 10),
                  _buildTheoryItem(
                    '3. In-Context Learning Advantage',
                    'Few-shot examples clarify ambiguous instructions and enforce strict formatting without fine-tuning model weights.',
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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProcedureStep('Step 1', 'Enter target task/query in the text area.'),
                  _buildProcedureStep('Step 2', 'Select prompting technique (Zero-Shot, Few-Shot, or Compare Both).'),
                  _buildProcedureStep('Step 3', 'If Few-Shot is selected, configure demonstration input-output pairs.'),
                  _buildProcedureStep('Step 4', 'Click ▶ RUN PRACTICAL to execute live model requests.'),
                  _buildProcedureStep('Step 5', 'Expand VIEW EXACT PROMPT SENT TO AI to inspect prompt construction.'),
                  _buildProcedureStep('Step 6', 'Compare format, latency, and response precision across techniques.'),
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
              _isLoading ? 'EXECUTING PROMPTS...' : 'RUN PRACTICAL',
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
            _loadingStatus,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dispatching generated prompt payloads to Generative AI model',
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
                  'PROMPT EXECUTION ERROR',
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

  Widget _buildResultsView(PromptResult result) {
    if (result.method == 'compare' && result.subResults != null) {
      final zeroResult = result.subResults!.firstWhere(
        (r) => r.method == 'zero_shot',
        orElse: () => result.subResults![0],
      );
      final fewResult = result.subResults!.firstWhere(
        (r) => r.method == 'few_shot',
        orElse: () => result.subResults![1],
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIDE-BY-SIDE PROMPTING COMPARISON',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // ZERO-SHOT CARD
          PromptResultCard(
            result: zeroResult,
            cardTitle: '1. Zero-Shot Result (No Examples)',
            accentColor: AppTheme.primaryCyan,
          ),

          // FEW-SHOT CARD
          PromptResultCard(
            result: fewResult,
            cardTitle: '2. Few-Shot Result (With Examples)',
            accentColor: AppTheme.secondaryTeal,
          ),

          // COMPARISON OBSERVATION CARD
          _buildComparisonObservationCard(zeroResult, fewResult),
        ],
      );
    }

    // Single result mode
    return PromptResultCard(
      result: result,
      cardTitle: result.method == 'zero_shot'
          ? 'Zero-Shot Result'
          : 'Few-Shot Result',
      accentColor: result.method == 'zero_shot'
          ? AppTheme.primaryCyan
          : AppTheme.secondaryTeal,
    );
  }

  Widget _buildComparisonObservationCard(
      PromptResult zero, PromptResult few) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.academicGold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                size: 16,
                color: AppTheme.academicGold,
              ),
              const SizedBox(width: 8),
              Text(
                'PROMPT ENGINEERING OBSERVATION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.academicGold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Zero-Shot Prompting produces direct model inference without contextual demonstration.\n'
            '• Few-Shot Prompting provides in-context demonstration examples, guiding the AI model toward consistent formatting and task constraints.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.45,
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
            'Zero-shot and few-shot prompting techniques were tested successfully using a Generative AI model.',
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
