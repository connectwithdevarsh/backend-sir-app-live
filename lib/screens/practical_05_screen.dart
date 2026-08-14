import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_execution_result.dart';
import '../services/prompt_refinement_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_type_selector.dart';
import '../widgets/prompt_editor_card.dart';
import '../widgets/prompt_refinement_controls.dart';
import '../widgets/execution_result_card.dart';
import '../widgets/comparison_card.dart';
import '../widgets/observation_card.dart';

class Practical05Screen extends StatefulWidget {
  const Practical05Screen({super.key});

  @override
  State<Practical05Screen> createState() => _Practical05ScreenState();
}

class _Practical05ScreenState extends State<Practical05Screen> {
  // State
  String _selectedTaskType = 'email'; // 'email', 'concept', 'custom'
  final TextEditingController _basicPromptController = TextEditingController();
  final TextEditingController _refinedPromptController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();

  bool _isBasicLoading = false;
  bool _isRefinedLoading = false;
  PromptExecutionResult? _beforeResult;
  PromptExecutionResult? _afterResult;
  String? _errorMessage;

  // Comparison Evaluation State
  final Map<String, String> _evaluationRatings = {
    'relevance': 'Better',
    'clarity': 'Better',
    'structure': 'Better',
    'instruction': 'Better',
    'specificity': 'Better',
  };

  // Collapsible Section State
  bool _isTheoryExpanded = false;
  bool _isProcedureExpanded = false;

  @override
  void initState() {
    super.initState();
    _applyTaskTypePreset('email');
  }

  @override
  void dispose() {
    _basicPromptController.dispose();
    _refinedPromptController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _applyTaskTypePreset(String taskType) {
    setState(() {
      _selectedTaskType = taskType;
      _beforeResult = null;
      _afterResult = null;
      _errorMessage = null;

      switch (taskType.toLowerCase()) {
        case 'concept':
          _basicPromptController.text = 'Explain Machine Learning.';
          _refinedPromptController.text =
              'Explain Machine Learning to a first-year Diploma IT student.\n\n'
              'Include:\n'
              '1. Simple definition\n'
              '2. How it works at a high level\n'
              '3. Three real-world examples\n'
              '4. Difference between AI and Machine Learning\n\n'
              'Use simple language and bullet points. Keep the explanation under 300 words.';
          _observationController.text =
              'Refined prompt provided targeted audience, numbered structure, and word count constraints.';
          break;

        case 'custom':
          _basicPromptController.text = 'Write a summary of cloud computing.';
          _refinedPromptController.text =
              'Write a concise technical summary of Cloud Computing for IT engineers.\n\n'
              'Structure with:\n'
              '- Definition & Core Value Proposition\n'
              '- Top 3 Service Models (IaaS, PaaS, SaaS) with 1 real-world example each\n'
              '- Key benefits: Scalability, Cost Efficiency, Security\n\n'
              'Format as clean bullet points without generic introductory filler.';
          _observationController.text =
              'Refined prompt added specific architectural models and direct bullet formatting.';
          break;

        case 'email':
        default:
          _basicPromptController.text =
              'Write an email to my teacher asking for an extension for submitting an assignment.';
          _refinedPromptController.text =
              'Write a formal and polite email to my Artificial Intelligence subject teacher requesting a two-day extension for submitting my practical assignment.\n\n'
              'Include:\n'
              '- Clear Subject line\n'
              '- Respectful greeting\n'
              '- Reason for delay\n'
              '- Proposed new submission date\n'
              '- Professional closing\n\n'
              'Keep the email concise, professional, and well-structured.';
          _observationController.text =
              'Refined prompt specified exact fields (subject line, deadline, reason) resulting in a professional email.';
          break;
      }
    });
  }

  Future<void> _runBasicPrompt() async {
    final promptText = _basicPromptController.text.trim();
    if (promptText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a basic prompt before running.', style: GoogleFonts.inter(fontSize: 12)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isBasicLoading = true;
      _errorMessage = null;
    });

    final result = await PromptRefinementApiService.runPrompt(prompt: promptText);

    if (!mounted) return;

    setState(() {
      _isBasicLoading = false;
      if (result.success) {
        _beforeResult = result;
        _errorMessage = null;
      } else {
        _errorMessage = result.error ?? 'Failed to execute basic prompt.';
      }
    });
  }

  Future<void> _runRefinedPrompt() async {
    final promptText = _refinedPromptController.text.trim();
    if (promptText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter or refine your prompt before running.', style: GoogleFonts.inter(fontSize: 12)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isRefinedLoading = true;
      _errorMessage = null;
    });

    final result = await PromptRefinementApiService.runPrompt(prompt: promptText);

    if (!mounted) return;

    setState(() {
      _isRefinedLoading = false;
      if (result.success) {
        _afterResult = result;
        _errorMessage = null;
      } else {
        _errorMessage = result.error ?? 'Failed to execute refined prompt.';
      }
    });
  }

  void _resetLaboratory() {
    setState(() {
      _applyTaskTypePreset(_selectedTaskType);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 05 state reset to initial preset.', style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnyLoading = _isBasicLoading || _isRefinedLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PRACTICAL 05',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'PROMPT DESIGN & REFINEMENT',
                    style: GoogleFonts.firaCode(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Design, Refine & Compare Generative AI Prompts',
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
            // Academic Metadata & Syllabus Outcome Banner
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

            // Section 1: Task Type Selector
            Text(
              '1. SELECT TASK TYPE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TaskTypeSelector(
              selectedTaskType: _selectedTaskType,
              isEnabled: !isAnyLoading,
              onTaskTypeChanged: (type) => _applyTaskTypePreset(type),
            ),

            const SizedBox(height: 20),

            // Section 2: Step A — Basic Prompt (Before)
            Text(
              '2. BASIC PROMPT (BEFORE REFINEMENT)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            PromptEditorCard(
              title: 'Basic Prompt',
              badgeText: 'Initial Draft',
              helperText: 'A simple, direct prompt without detailed context, constraints, or audience specifications.',
              controller: _basicPromptController,
              accentColor: AppTheme.primaryCyan,
              icon: Icons.edit_note_rounded,
              isEnabled: !isAnyLoading,
            ),

            const SizedBox(height: 12),

            // Button: Run Basic Prompt
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAnyLoading ? null : _runBasicPrompt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isBasicLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'GENERATING BASIC RESPONSE...',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'RUN BASIC PROMPT',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Display Before Output
            if (_beforeResult != null) ...[
              const SizedBox(height: 16),
              ExecutionResultCard(
                title: 'Before Refinement Output',
                result: _beforeResult!,
                accentColor: AppTheme.primaryCyan,
                icon: Icons.history_rounded,
              ),
            ],

            const SizedBox(height: 24),

            // Section 3: Step B — Refined Prompt (After)
            Text(
              '3. REFINE YOUR PROMPT (AFTER REFINEMENT)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentPurple,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // Interactive Refinement Assistant
            PromptRefinementControls(
              basicPrompt: _basicPromptController.text,
              isEnabled: !isAnyLoading,
              onRefinedPromptGenerated: (refinedText) {
                setState(() {
                  _refinedPromptController.text = refinedText;
                });
              },
            ),

            const SizedBox(height: 12),

            // Refined Prompt Editor Card
            PromptEditorCard(
              title: 'Refined Prompt',
              badgeText: 'Engineered Draft',
              helperText: 'Contains explicit constraints, persona, tone, audience, and structured formatting requirements.',
              controller: _refinedPromptController,
              accentColor: AppTheme.accentPurple,
              icon: Icons.auto_awesome_rounded,
              isEnabled: !isAnyLoading,
            ),

            const SizedBox(height: 12),

            // Button: Run Refined Prompt
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAnyLoading ? null : _runRefinedPrompt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isRefinedLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'GENERATING REFINED RESPONSE...',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'RUN REFINED PROMPT',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Display After Output
            if (_afterResult != null) ...[
              const SizedBox(height: 16),
              ExecutionResultCard(
                title: 'After Refinement Output',
                result: _afterResult!,
                accentColor: AppTheme.accentPurple,
                icon: Icons.auto_awesome_rounded,
              ),
            ],

            // Error Message Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_errorMessage!),
            ],

            // Step 4 & 5: Comparison & Evaluation (Enabled when both results exist)
            if (_beforeResult != null && _afterResult != null) ...[
              const SizedBox(height: 24),

              // Side-by-Side Comparison Card
              ComparisonCard(
                beforeResult: _beforeResult!,
                afterResult: _afterResult!,
                evaluationRatings: _evaluationRatings,
                onRatingChanged: (key, rating) {
                  setState(() {
                    _evaluationRatings[key] = rating;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Student Observation Notes Card
              ObservationCard(
                controller: _observationController,
                isEnabled: true,
              ),

              const SizedBox(height: 18),

              // Final GTU Result / Conclusion Banner
              _buildResultCard(),
            ],

            const SizedBox(height: 20),

            // Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isAnyLoading ? null : _resetLaboratory,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Academic Header Banner
  Widget _buildAcademicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 3: PROMPT ENGINEERING FUNDAMENTALS',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTeal,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Approx: 2 Hours',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
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
            '"Design and refine prompts for tasks such as email writing and concept explanation. Compare outputs before and after prompt refinement."',
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

  // Objectives Card
  Widget _buildObjectivesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
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
          '7 laboratory goals and outcomes',
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
                  'To design and refine prompts for tasks such as email writing and concept explanation and compare the generated outputs before and after prompt refinement.',
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
                _buildObjectiveItem('1', 'Create a basic prompt.'),
                _buildObjectiveItem('2', 'Execute the basic prompt using a real LLM.'),
                _buildObjectiveItem('3', 'Identify weaknesses in the basic prompt.'),
                _buildObjectiveItem('4', 'Refine the prompt using specific instructions and constraints.'),
                _buildObjectiveItem('5', 'Execute the refined prompt using the same LLM.'),
                _buildObjectiveItem('6', 'Compare both responses side-by-side.'),
                _buildObjectiveItem('7', 'Understand the empirical effect of prompt refinement.'),
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
          Text(
            '$num. ',
            style: GoogleFonts.firaCode(fontSize: 11.5, color: AppTheme.primaryCyan),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  // Theory Card
  Widget _buildTheoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isTheoryExpanded,
        onExpansionChanged: (exp) => setState(() => _isTheoryExpanded = exp),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Theory: Prompt Design & Refinement',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTheoryItem(
                  'What is Prompt Refinement?',
                  'Prompt refinement is the systematic process of improving an initial prompt by injecting relevant context, clear instructions, explicit constraints, target audience persona, output structure, and tone specifications.',
                ),
                _buildTheoryItem(
                  'Why Refine a Prompt?',
                  'Raw basic prompts often yield generic, overly conversational, or loosely structured responses. A refined prompt steers the LLM toward targeted, high-utility, and domain-appropriate outputs.',
                ),
                _buildTheoryItem(
                  'Key Engineering Dimensions:',
                  '1. Role & Persona (e.g. "You are an IT professor")\n2. Task Clarity (Action verbs)\n3. Context & Background\n4. Output Format (Bullets, JSON, formal letter)\n5. Constraints & Negative Constraints ("Keep under 300 words, no jargon")',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppTheme.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // Procedure Card
  Widget _buildProcedureCard() {
    final steps = [
      'Select a task type (Email Writing, Concept Explanation, or Custom).',
      'Enter or examine the basic prompt.',
      'Press ▶ RUN BASIC PROMPT to execute it against the real LLM.',
      'Observe the basic generated output, model name, and execution time.',
      'Identify structural weaknesses, missing details, or conversational fluff.',
      'Refine the prompt by adding audience, tone, format, and explicit constraints.',
      'Press ▶ RUN REFINED PROMPT to execute the refined prompt against the same LLM.',
      'Observe the refined output and latency.',
      'Compare Before vs After responses side-by-side and record analytical observations.',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isProcedureExpanded,
        onExpansionChanged: (exp) => setState(() => _isProcedureExpanded = exp),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Laboratory Procedure',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.key + 1}. ',
                        style: GoogleFonts.firaCode(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTeal,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Error Card
  Widget _buildErrorCard(String errorMsg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1515),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMsg,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
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

  // Result Card
  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryCyan.withValues(alpha: 0.15),
            AppTheme.secondaryTeal.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded, color: AppTheme.primaryCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'PRACTICAL CONCLUSION & RESULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The basic and refined prompts were executed using a real Generative AI model and their outputs were compared to observe the effect of prompt refinement.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
