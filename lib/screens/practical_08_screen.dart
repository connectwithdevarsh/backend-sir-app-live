import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_prompt_request.dart';
import '../models/task_prompt_result.dart';
import '../services/task_prompt_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/code_result_card.dart';
import '../widgets/optimization_controls.dart';
import '../widgets/prompt_editor_card.dart';
import '../widgets/source_input_card.dart';
import '../widgets/task_comparison_card.dart';
import '../widgets/task_result_card.dart';
import '../widgets/task_type_selector.dart';

/// Practical08Screen implements GTU Practical 08:
/// "Perform task-based prompt engineering for summarization, blog generation, and code generation. Optimize prompts for better output."
class Practical08Screen extends StatefulWidget {
  const Practical08Screen({super.key});

  @override
  State<Practical08Screen> createState() => _Practical08ScreenState();
}

class _Practical08ScreenState extends State<Practical08Screen> {
  // Currently active task: "summarization", "blog", "code"
  String _selectedTask = 'summarization';

  // Input text controllers
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _basicPromptController = TextEditingController();
  final TextEditingController _optimizedPromptController = TextEditingController();
  final TextEditingController _blogKeywordsController = TextEditingController();
  final TextEditingController _observationController = TextEditingController(
    text:
        'The basic prompt produced a generic output lacking explicit structure. The optimized prompt added length constraints, clear audience tone, and target formatting, producing a significantly higher-quality result.',
  );

  // Summarization Optimization Parameters
  String _summaryLength = '100 words';
  String _summaryAudience = 'Diploma IT Student';
  String _summaryFormat = 'Bullet Points';
  String _summaryFocus = 'Main Ideas';

  // Blog Generation Optimization Parameters
  String _blogAudience = 'Students';
  String _blogTone = 'Informative & Friendly';
  String _blogLength = 'Medium (~600 words)';

  // Code Generation Optimization Parameters
  String _codeLanguage = 'Python';
  bool _includeComments = true;
  bool _includeValidation = true;
  bool _useFunction = true;
  bool _explainCode = true;
  bool _includeSampleIO = true;

  // Execution state
  bool _isLoadingBasic = false;
  bool _isLoadingOptimized = false;
  bool _isLoadingBoth = false;
  String? _errorMessage;

  TaskPromptResult? _basicResult;
  TaskPromptResult? _optimizedResult;

  // Student Evaluation Ratings
  final Map<String, String> _evaluationRatings = {
    'relevance': 'Better',
    'structure': 'Better',
    'audience': 'Better',
    'clarity': 'Better',
    'constraints': 'Better',
  };

  // Educational Improvement Checklist
  final Map<String, bool> _improvementChecklist = {
    'Added context & domain specifications': true,
    'Defined target audience & persona': true,
    'Added output formatting constraints': true,
    'Specified length / word limits': true,
    'Included technical & error handling requirements': true,
  };

  @override
  void initState() {
    super.initState();
    _applyTaskDefaults('summarization');
  }

  @override
  void dispose() {
    _inputController.dispose();
    _basicPromptController.dispose();
    _optimizedPromptController.dispose();
    _blogKeywordsController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _applyTaskDefaults(String taskType) {
    setState(() {
      _selectedTask = taskType;
      _basicResult = null;
      _optimizedResult = null;
      _errorMessage = null;

      if (taskType == 'summarization') {
        _inputController.text =
            'Artificial Intelligence is a field of computer science that focuses on creating systems capable of performing tasks that normally require human intelligence. These tasks include learning, reasoning, problem solving, language understanding and perception. Machine Learning is a subset of AI that allows systems to learn from data.';
        _basicPromptController.text = 'Summarize the following text.';
      } else if (taskType == 'blog') {
        _inputController.text = 'Artificial Intelligence in Education';
        _basicPromptController.text =
            'Write a blog about Artificial Intelligence in Education.';
        _blogKeywordsController.text = 'personalization, coding labs, diploma IT';
      } else if (taskType == 'code') {
        _inputController.text =
            'Write a Python program to check whether a number is prime.';
        _basicPromptController.text =
            'Write Python code to check whether a number is prime.';
      }

      _rebuildOptimizedPrompt();
    });
  }

  void _rebuildOptimizedPrompt() {
    final input = _inputController.text.trim();

    if (_selectedTask == 'summarization') {
      _optimizedPromptController.text =
          '''Summarize the following text for a $_summaryAudience in approximately $_summaryLength.

Focus: $_summaryFocus.
Output Format: $_summaryFormat.

Instructions:
1. Extract key concepts clearly.
2. Keep the language accessible for the target audience.
3. Adhere strictly to the requested $_summaryFormat structure.
4. Avoid adding information not present in the source text.

Source Text:
$input''';
    } else if (_selectedTask == 'blog') {
      final kw = _blogKeywordsController.text.trim();
      final kwText = kw.isNotEmpty ? '\nKey Keywords: $kw' : '';

      _optimizedPromptController.text =
          '''Write an informative blog post on the topic: "$input".

Target Audience: $_blogAudience
Tone & Style: $_blogTone
Target Length: $_blogLength$kwText

Blog Structure Requirements:
1. Catchy Title
2. Introduction with an engaging hook
3. Key Benefits & Concepts
4. Real-world Practical Applications
5. Challenges or Future Outlook
6. Conclusion

Guidelines:
- Use clear markdown headings and short paragraphs.
- Keep content student-friendly and focused.''';
    } else if (_selectedTask == 'code') {
      final List<String> reqs = [];
      if (_useFunction) reqs.add('• Create a clean modular function.');
      if (_includeValidation) reqs.add('• Include input validation and edge case handling.');
      if (_includeComments) reqs.add('• Add concise inline comments.');
      if (_includeSampleIO) reqs.add('• Include sample input/output execution tests.');
      if (_explainCode) reqs.add('• Briefly explain the code logic after the program.');

      _optimizedPromptController.text =
          '''Write a complete, high-quality $_codeLanguage program for the following problem statement:

Problem Statement:
$input

Requirements:
${reqs.join('\n')}''';
    }
  }

  Future<void> _runBasicPrompt() async {
    final input = _inputController.text.trim();
    final prompt = _basicPromptController.text.trim();

    if (input.isEmpty) {
      _showToast('Please enter source text or problem statement.');
      return;
    }

    setState(() {
      _isLoadingBasic = true;
      _errorMessage = null;
    });

    final req = TaskPromptRequest(
      taskType: _selectedTask,
      promptType: 'basic',
      input: input,
      prompt: prompt,
      language: _codeLanguage,
    );

    final res = await TaskPromptApiService.runTaskPrompt(req);

    if (!mounted) return;

    setState(() {
      _isLoadingBasic = false;
      if (res.success) {
        _basicResult = res;
        _errorMessage = null;
      } else {
        _errorMessage = res.error ?? 'Failed to execute basic prompt.';
      }
    });
  }

  Future<void> _runOptimizedPrompt() async {
    final input = _inputController.text.trim();
    final prompt = _optimizedPromptController.text.trim();

    if (input.isEmpty) {
      _showToast('Please enter source text or problem statement.');
      return;
    }

    setState(() {
      _isLoadingOptimized = true;
      _errorMessage = null;
    });

    final req = TaskPromptRequest(
      taskType: _selectedTask,
      promptType: 'optimized',
      input: input,
      prompt: prompt,
      language: _codeLanguage,
      length: _summaryLength,
      audience: _summaryAudience,
      summaryFormat: _summaryFormat,
      focus: _summaryFocus,
      tone: _blogTone,
      keywords: _blogKeywordsController.text,
      includeComments: _includeComments,
      includeValidation: _includeValidation,
      useFunction: _useFunction,
      explainCode: _explainCode,
      includeSampleIO: _includeSampleIO,
    );

    final res = await TaskPromptApiService.runTaskPrompt(req);

    if (!mounted) return;

    setState(() {
      _isLoadingOptimized = false;
      if (res.success) {
        _optimizedResult = res;
        _errorMessage = null;
      } else {
        _errorMessage = res.error ?? 'Failed to execute optimized prompt.';
      }
    });
  }

  Future<void> _runBothAndCompare() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      _showToast('Please enter source text or problem statement.');
      return;
    }

    setState(() {
      _isLoadingBoth = true;
      _errorMessage = null;
    });

    await _runBasicPrompt();
    await _runOptimizedPrompt();

    if (!mounted) return;

    setState(() {
      _isLoadingBoth = false;
    });
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetLaboratory() {
    setState(() {
      _applyTaskDefaults('summarization');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 08 state reset to default.',
            style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoadingBasic || _isLoadingOptimized || _isLoadingBoth;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PRACTICAL 08',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppTheme.primaryCyan.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'TASK PROMPTING',
                    style: GoogleFonts.firaCode(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Summarization, Blog & Code Generation',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Academic Banner
            _buildAcademicHeader(),

            const SizedBox(height: 16),

            // Collapsible Aim & Objectives
            _buildObjectivesCard(),

            const SizedBox(height: 12),

            // Collapsible Theory Card
            _buildTheoryCard(),

            const SizedBox(height: 12),

            // Collapsible Procedure Card
            _buildProcedureCard(),

            const SizedBox(height: 20),

            // Section 1: Task Selector Tabs
            Text(
              '1. SELECT GENERATIVE AI TASK',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            TaskTypeSelector(
              selectedTask: _selectedTask,
              onTaskChanged: (t) => _applyTaskDefaults(t),
              isEnabled: !isBusy,
            ),

            const SizedBox(height: 18),

            // Section 2: Input Content Editor
            SourceInputCard(
              title: _selectedTask == 'summarization'
                  ? 'SOURCE TEXT TO SUMMARIZE'
                  : (_selectedTask == 'blog'
                      ? 'BLOG TOPIC'
                      : 'PROGRAMMING PROBLEM STATEMENT'),
              hintText: _selectedTask == 'summarization'
                  ? 'Enter source article text...'
                  : (_selectedTask == 'blog'
                      ? 'Enter blog topic...'
                      : 'Enter programming task...'),
              controller: _inputController,
              isEnabled: !isBusy,
              onClear: () {
                setState(() {
                  _inputController.clear();
                  _rebuildOptimizedPrompt();
                });
              },
            ),

            const SizedBox(height: 18),

            // Section 3: Basic Prompt Editor
            PromptEditorCard(
              title: 'BASIC PROMPT',
              promptType: 'basic',
              controller: _basicPromptController,
              isEnabled: !isBusy,
            ),

            const SizedBox(height: 16),

            // Section 4: Prompt Optimization Controls
            OptimizationControls(
              taskType: _selectedTask,
              isEnabled: !isBusy,
              summaryLength: _summaryLength,
              summaryAudience: _summaryAudience,
              summaryFormat: _summaryFormat,
              summaryFocus: _summaryFocus,
              blogAudience: _blogAudience,
              blogTone: _blogTone,
              blogLength: _blogLength,
              keywordsController: _blogKeywordsController,
              codeLanguage: _codeLanguage,
              includeComments: _includeComments,
              includeValidation: _includeValidation,
              useFunction: _useFunction,
              explainCode: _explainCode,
              includeSampleIO: _includeSampleIO,
              onSummaryLengthChanged: (v) => setState(() {
                _summaryLength = v;
                _rebuildOptimizedPrompt();
              }),
              onSummaryAudienceChanged: (v) => setState(() {
                _summaryAudience = v;
                _rebuildOptimizedPrompt();
              }),
              onSummaryFormatChanged: (v) => setState(() {
                _summaryFormat = v;
                _rebuildOptimizedPrompt();
              }),
              onSummaryFocusChanged: (v) => setState(() {
                _summaryFocus = v;
                _rebuildOptimizedPrompt();
              }),
              onBlogAudienceChanged: (v) => setState(() {
                _blogAudience = v;
                _rebuildOptimizedPrompt();
              }),
              onBlogToneChanged: (v) => setState(() {
                _blogTone = v;
                _rebuildOptimizedPrompt();
              }),
              onBlogLengthChanged: (v) => setState(() {
                _blogLength = v;
                _rebuildOptimizedPrompt();
              }),
              onCodeLanguageChanged: (v) => setState(() {
                _codeLanguage = v;
                _rebuildOptimizedPrompt();
              }),
              onCommentsChanged: (v) => setState(() {
                _includeComments = v;
                _rebuildOptimizedPrompt();
              }),
              onValidationChanged: (v) => setState(() {
                _includeValidation = v;
                _rebuildOptimizedPrompt();
              }),
              onFunctionChanged: (v) => setState(() {
                _useFunction = v;
                _rebuildOptimizedPrompt();
              }),
              onExplainChanged: (v) => setState(() {
                _explainCode = v;
                _rebuildOptimizedPrompt();
              }),
              onSampleIOChanged: (v) => setState(() {
                _includeSampleIO = v;
                _rebuildOptimizedPrompt();
              }),
            ),

            const SizedBox(height: 16),

            // Section 5: Optimized Prompt Editor
            PromptEditorCard(
              title: 'OPTIMIZED PROMPT',
              promptType: 'optimized',
              controller: _optimizedPromptController,
              isEnabled: !isBusy,
            ),

            const SizedBox(height: 20),

            // Section 6: Action Buttons (Run Basic, Run Optimized, Compare Both)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : _runBasicPrompt,
                    icon: _isLoadingBasic
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 16),
                    label: Text(
                      'RUN BASIC PROMPT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryCyan,
                      side: BorderSide(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : _runOptimizedPrompt,
                    icon: _isLoadingOptimized
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(
                      'RUN OPTIMIZED PROMPT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryTeal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Run Both & Compare Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isBusy ? null : _runBothAndCompare,
                icon: _isLoadingBoth
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                      )
                    : const Icon(Icons.bolt_rounded, size: 18),
                label: Text(
                  '⚡ RUN BOTH & COMPARE OUTPUTS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            // Error Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_errorMessage!),
            ],

            // Section 7: Output Results
            if (_basicResult != null) ...[
              const SizedBox(height: 20),
              _selectedTask == 'code'
                  ? CodeResultCard(result: _basicResult!)
                  : TaskResultCard(result: _basicResult!),
            ],

            if (_optimizedResult != null) ...[
              const SizedBox(height: 20),
              _selectedTask == 'code'
                  ? CodeResultCard(result: _optimizedResult!)
                  : TaskResultCard(result: _optimizedResult!),
            ],

            // Section 8: Side-by-Side Comparison Card & Checklist
            if (_basicResult != null && _optimizedResult != null) ...[
              const SizedBox(height: 24),
              TaskComparisonCard(
                basicResult: _basicResult!,
                optimizedResult: _optimizedResult!,
                evaluationRatings: _evaluationRatings,
                onRatingChanged: (k, v) => setState(() => _evaluationRatings[k] = v),
                improvementChecklist: _improvementChecklist,
                onChecklistChanged: (k, v) => setState(() => _improvementChecklist[k] = v),
              ),

              const SizedBox(height: 16),

              // Student Observation Notes Card
              _buildObservationCard(),

              const SizedBox(height: 18),

              // GTU Result Certificate Card
              _buildResultCard(),
            ],

            const SizedBox(height: 20),

            // Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _resetLaboratory,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'RESET LABORATORY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 4: ADVANCED PROMPTING TECHNIQUES',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Approx: 2 Hours',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'OFFICIAL GTU OUTCOME',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"Perform task-based prompt engineering for summarization, blog generation, and code generation. Optimize prompts for better output."',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Aim & Practical Objectives',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '8 laboratory goals and outcomes',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aim:',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  'To perform task-based prompt engineering for summarization, blog generation, and code generation and optimize prompts for better output.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  'Objectives:',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTeal,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                _buildObjectiveItem('1', 'Understand task-specific prompting principles.'),
                _buildObjectiveItem('2', 'Create prompts for different AI tasks.'),
                _buildObjectiveItem('3', 'Generate summaries using AI.'),
                _buildObjectiveItem('4', 'Generate blog content using AI.'),
                _buildObjectiveItem('5', 'Generate code using AI.'),
                _buildObjectiveItem('6', 'Identify weaknesses in basic prompts.'),
                _buildObjectiveItem('7', 'Optimize prompts using context and constraints.'),
                _buildObjectiveItem('8', 'Compare basic and optimized outputs.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$num. ', style: GoogleFonts.firaCode(fontSize: 11.5, color: AppTheme.primaryCyan)),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildTheoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Theory: Task-Based Prompt Engineering',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Summarization, Blog & Code generation theory',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task-Based Prompt Engineering:',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12.5)),
                const SizedBox(height: 4),
                Text(
                  'Task-based prompt engineering means designing prompts according to the specific task that the AI model needs to perform. Different tasks require different instructions, context, constraints, and output formats.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text('1. Summarization:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12)),
                Text('Defines source content, length, audience, key focus, and format (bullets vs paragraphs).', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 6),
                Text('2. Blog Generation:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12)),
                Text('Defines topic, audience persona, tone, section headings, length, and key keywords.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 6),
                Text('3. Code Generation:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.accentViolet, fontSize: 12)),
                Text('Defines programming language, problem statement, modular functions, comments, validation, and sample tests.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Procedure & Experimental Steps',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '11-step laboratory workflow',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildObjectiveItem('1', 'Select a task (Summarization / Blog / Code).'),
                _buildObjectiveItem('2', 'Enter the required input content or problem.'),
                _buildObjectiveItem('3', 'Inspect the basic prompt.'),
                _buildObjectiveItem('4', 'Run the basic prompt on the real LLM.'),
                _buildObjectiveItem('5', 'Observe limitations in the basic output.'),
                _buildObjectiveItem('6', 'Add relevant context, audience, and constraints.'),
                _buildObjectiveItem('7', 'Generate the optimized prompt.'),
                _buildObjectiveItem('8', 'Run the optimized prompt on the real LLM.'),
                _buildObjectiveItem('9', 'Compare basic vs optimized outputs side-by-side.'),
                _buildObjectiveItem('10', 'Evaluate criteria (Relevance, Structure, Tone, etc.).'),
                _buildObjectiveItem('11', 'Record student observations and conclusions.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STUDENT OBSERVATION NOTES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _observationController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe how the optimized prompt changed the output...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.secondaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'PRACTICAL 08 EXPERIMENTAL RESULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The selected task was performed using a basic prompt and an optimized prompt. The generated outputs were compared to observe the effect of task-specific prompt optimization.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String errorMsg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prompt Execution Error',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  errorMsg,
                  style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
