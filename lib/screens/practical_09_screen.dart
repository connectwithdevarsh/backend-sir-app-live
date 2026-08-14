import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/software_ai_request.dart';
import '../models/software_ai_result.dart';
import '../services/software_ai_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/before_after_code_card.dart';
import '../widgets/code_editor_card.dart';
import '../widgets/debug_result_card.dart';
import '../widgets/explanation_result_card.dart';
import '../widgets/generated_code_card.dart';
import '../widgets/prompt_viewer_card.dart';
import '../widgets/software_task_selector.dart';

/// Practical09Screen implements GTU Practical 09:
/// "Use AI tools for software development tasks such as code generation, debugging, and code explanation."
class Practical09Screen extends StatefulWidget {
  const Practical09Screen({super.key});

  @override
  State<Practical09Screen> createState() => _Practical09ScreenState();
}

class _Practical09ScreenState extends State<Practical09Screen> {
  // Selected feature task: "code_generation", "debugging", "code_explanation"
  String _selectedTask = 'code_generation';

  // Programming language selection
  String _selectedLanguage = 'Python';
  final TextEditingController _customLanguageController = TextEditingController();

  // Code Generation Controllers
  final TextEditingController _problemController = TextEditingController(
    text:
        'Create a Python program that accepts marks of three subjects and calculates the average and grade.',
  );
  final TextEditingController _requirementsController = TextEditingController(
    text:
        'Use a function. Validate that marks are between 0 and 100. Display average and grade.',
  );

  // Debugging Controllers
  final TextEditingController _debugCodeController = TextEditingController(
    text: '''def calculate_average(numbers):
    total = sum(numbers)
    return total / len(numbers)''',
  );
  final TextEditingController _debugErrorController = TextEditingController(
    text: 'ZeroDivisionError: division by zero',
  );
  final TextEditingController _debugExpectedController = TextEditingController(
    text: 'Return 0 when the list is empty.',
  );

  // Explanation Controllers
  final TextEditingController _explainCodeController = TextEditingController(
    text: '''def calculate_average(numbers):
    if not numbers:
        return 0

    total = sum(numbers)
    return total / len(numbers)''',
  );
  String _explanationLevel = 'Beginner';
  final Map<String, bool> _explanationFocus = {
    'Overall purpose': true,
    'Functions': true,
    'Variables': false,
    'Control flow': true,
    'Key logic': true,
    'Potential issues': false,
  };

  // Student Observation Controller
  final TextEditingController _observationController = TextEditingController(
    text:
        'AI code generation created a modular function with input validation. Debugging correctly identified the ZeroDivisionError guard clause necessity. Code explanation broke down execution flow clearly for beginners.',
  );

  // Execution states
  bool _isLoading = false;
  String? _errorMessage;
  SoftwareAiResult? _aiResult;

  @override
  void dispose() {
    _customLanguageController.dispose();
    _problemController.dispose();
    _requirementsController.dispose();
    _debugCodeController.dispose();
    _debugErrorController.dispose();
    _debugExpectedController.dispose();
    _explainCodeController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  String get _effectiveLanguage {
    if (_selectedLanguage == 'Custom') {
      return _customLanguageController.text.trim().isNotEmpty
          ? _customLanguageController.text.trim()
          : 'Python';
    }
    return _selectedLanguage;
  }

  String _buildPreviewPrompt() {
    final lang = _effectiveLanguage;

    if (_selectedTask == 'code_generation') {
      return '''You are an experienced software developer.

Programming Language:
$lang

Task / Requirement:
${_problemController.text.trim()}

Specific Requirements:
${_requirementsController.text.trim()}

Instructions:
1. Generate clean, well-structured, and readable code.
2. Include appropriate inline comments explaining non-trivial logic.
3. Ensure the code is self-contained.
4. After the code, provide a short step-by-step explanation.''';
    } else if (_selectedTask == 'debugging') {
      return '''You are an experienced software debugging assistant.

Programming Language:
$lang

Source Code:
${_debugCodeController.text.trim()}

Error Message:
${_debugErrorController.text.trim()}

Expected Behavior:
${_debugExpectedController.text.trim()}

Identify the likely cause of the problem.

Provide:
1. Problem identification
2. Cause analysis
3. Corrected code
4. Fix explanation''';
    } else {
      final selectedFocus = _explanationFocus.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(', ');

      return '''You are an experienced programming instructor.

Explain the following $lang code for a $_explanationLevel learner.

Code:
${_explainCodeController.text.trim()}

Focus on:
${selectedFocus.isNotEmpty ? selectedFocus : 'Overall purpose, Control flow'}

Explain:
1. Overall purpose
2. Important components
3. Program flow
4. Key logic''';
    }
  }

  Future<void> _executeSoftwareTask() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _aiResult = null;
    });

    final List<String> activeFocus = _explanationFocus.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final req = SoftwareAiRequest(
      taskType: _selectedTask,
      language: _effectiveLanguage,
      problem: _problemController.text,
      requirements: _requirementsController.text,
      code: _selectedTask == 'debugging'
          ? _debugCodeController.text
          : _explainCodeController.text,
      error: _debugErrorController.text,
      expectedBehavior: _debugExpectedController.text,
      explanationLevel: _explanationLevel,
      focus: activeFocus,
    );

    try {
      final res = await SoftwareAiApiService.runSoftwareTask(req);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (res.success) {
          _aiResult = res;
          _errorMessage = null;
        } else {
          _errorMessage = res.error ?? 'Failed to execute software task.';
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _resetLaboratory() {
    setState(() {
      _selectedTask = 'code_generation';
      _selectedLanguage = 'Python';
      _problemController.text =
          'Create a Python program that accepts marks of three subjects and calculates the average and grade.';
      _requirementsController.text =
          'Use a function and validate that marks are between 0 and 100.';
      _debugCodeController.text =
          'def calculate_average(numbers):\n    total = sum(numbers)\n    return total / len(numbers)';
      _debugErrorController.text = 'ZeroDivisionError: division by zero';
      _debugExpectedController.text = 'Return 0 when the list is empty.';
      _explainCodeController.text =
          'def calculate_average(numbers):\n    if not numbers:\n        return 0\n    total = sum(numbers)\n    return total / len(numbers)';
      _explanationLevel = 'Beginner';
      _aiResult = null;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 09 state reset to default.',
            style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'PRACTICAL 09',
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
                    color: AppTheme.accentPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppTheme.accentPurple.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'AI SOFTWARE ASSISTANT',
                    style: GoogleFonts.firaCode(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Code Generation • Debugging • Code Explanation',
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
            // Academic Header Banner
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

            const SizedBox(height: 12),

            // Collapsible AI Limitations Card
            _buildLimitationsCard(),

            const SizedBox(height: 20),

            // Section 1: Task Feature Selector Tabs
            Text(
              '1. SELECT SOFTWARE ASSISTANT FEATURE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            SoftwareTaskSelector(
              selectedTask: _selectedTask,
              onTaskChanged: (task) {
                setState(() {
                  _selectedTask = task;
                  _aiResult = null;
                  _errorMessage = null;
                });
              },
              isEnabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Programming Language Selector Dropdown
            _buildLanguageSelector(),

            const SizedBox(height: 16),

            // Section 2: Inputs per Selected Task Feature
            if (_selectedTask == 'code_generation') _buildCodeGenerationInputs(),
            if (_selectedTask == 'debugging') _buildDebuggingInputs(),
            if (_selectedTask == 'code_explanation') _buildExplanationInputs(),

            const SizedBox(height: 16),

            // Prompt Viewer Card (Exact Prompt Sent to LLM)
            PromptViewerCard(
              title: 'EXACT PROMPT SENT TO AI',
              prompt: _buildPreviewPrompt(),
              accentColor: _selectedTask == 'debugging'
                  ? AppTheme.accentPurple
                  : (_selectedTask == 'code_explanation'
                      ? AppTheme.secondaryTeal
                      : AppTheme.primaryCyan),
            ),

            const SizedBox(height: 20),

            // Section 3: Execution Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _executeSoftwareTask,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Icon(
                        _selectedTask == 'debugging'
                            ? Icons.bug_report_rounded
                            : (_selectedTask == 'code_explanation'
                                ? Icons.lightbulb_rounded
                                : Icons.auto_awesome_rounded),
                        size: 20,
                      ),
                label: Text(
                  _isLoading
                      ? 'PROCESSING REQUEST...'
                      : (_selectedTask == 'debugging'
                          ? '🐞 DEBUG CODE'
                          : (_selectedTask == 'code_explanation'
                              ? '💡 EXPLAIN CODE'
                              : '▶ GENERATE CODE')),
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTask == 'debugging'
                      ? AppTheme.accentPurple
                      : (_selectedTask == 'code_explanation'
                          ? AppTheme.secondaryTeal
                          : AppTheme.primaryCyan),
                  foregroundColor: _selectedTask == 'debugging' ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            // Error Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_errorMessage!),
            ],

            // Section 4: Result Displays per Task Feature
            if (_aiResult != null) ...[
              const SizedBox(height: 20),

              if (_selectedTask == 'code_generation') ...[
                GeneratedCodeCard(
                  result: _aiResult!,
                  language: _effectiveLanguage,
                ),
              ],

              if (_selectedTask == 'debugging') ...[
                DebugResultCard(
                  result: _aiResult!,
                  language: _effectiveLanguage,
                ),
                const SizedBox(height: 16),
                BeforeAfterCodeCard(
                  originalCode: _debugCodeController.text,
                  correctedCode: _aiResult!.extractCodeBlock(_effectiveLanguage),
                ),
              ],

              if (_selectedTask == 'code_explanation') ...[
                ExplanationResultCard(
                  result: _aiResult!,
                ),
              ],

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
                onPressed: _isLoading ? null : _resetLaboratory,
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

  Widget _buildLanguageSelector() {
    final languages = ['Python', 'JavaScript', 'Dart', 'Java', 'C', 'C++', 'Custom'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded, color: AppTheme.primaryCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'PROGRAMMING LANGUAGE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                isExpanded: true,
                dropdownColor: const Color(0xFF0F172A),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryCyan),
                onChanged: !_isLoading
                    ? (val) {
                        if (val != null) setState(() => _selectedLanguage = val);
                      }
                    : null,
                items: languages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
              ),
            ),
          ),
          if (_selectedLanguage == 'Custom') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customLanguageController,
              enabled: !_isLoading,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter language (e.g. Go, Rust, Kotlin)...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeGenerationInputs() {
    return Column(
      children: [
        CodeEditorCard(
          title: 'PROBLEM / REQUIREMENT STATEMENT',
          hintText: 'Enter software problem or program requirement...',
          controller: _problemController,
          isEnabled: !_isLoading,
          isMonospace: false,
          maxLines: 3,
          onClear: () => setState(() => _problemController.clear()),
          accentColor: AppTheme.primaryCyan,
        ),
        const SizedBox(height: 12),
        CodeEditorCard(
          title: 'OPTIONAL SPECIFIC REQUIREMENTS',
          hintText: 'e.g. Use modular functions, validate input ranges...',
          controller: _requirementsController,
          isEnabled: !_isLoading,
          isMonospace: false,
          maxLines: 2,
          onClear: () => setState(() => _requirementsController.clear()),
          accentColor: AppTheme.primaryCyan,
        ),
      ],
    );
  }

  Widget _buildDebuggingInputs() {
    return Column(
      children: [
        CodeEditorCard(
          title: 'SOURCE CODE (WITH BUG)',
          hintText: 'Paste code containing an error or bug...',
          controller: _debugCodeController,
          isEnabled: !_isLoading,
          isMonospace: true,
          maxLines: 5,
          onClear: () => setState(() => _debugCodeController.clear()),
          accentColor: AppTheme.accentPurple,
        ),
        const SizedBox(height: 12),
        CodeEditorCard(
          title: 'ERROR MESSAGE / BUG SYMPTOM',
          hintText: 'Paste traceback error message or describe incorrect behavior...',
          controller: _debugErrorController,
          isEnabled: !_isLoading,
          isMonospace: true,
          maxLines: 2,
          onClear: () => setState(() => _debugErrorController.clear()),
          accentColor: AppTheme.accentPurple,
        ),
        const SizedBox(height: 12),
        CodeEditorCard(
          title: 'EXPECTED BEHAVIOR (OPTIONAL)',
          hintText: 'Describe expected result or correct behavior...',
          controller: _debugExpectedController,
          isEnabled: !_isLoading,
          isMonospace: false,
          maxLines: 2,
          onClear: () => setState(() => _debugExpectedController.clear()),
          accentColor: AppTheme.accentPurple,
        ),
      ],
    );
  }

  Widget _buildExplanationInputs() {
    return Column(
      children: [
        CodeEditorCard(
          title: 'SOURCE CODE TO EXPLAIN',
          hintText: 'Paste code to analyze and explain...',
          controller: _explainCodeController,
          isEnabled: !_isLoading,
          isMonospace: true,
          maxLines: 5,
          onClear: () => setState(() => _explainCodeController.clear()),
          accentColor: AppTheme.secondaryTeal,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXPLANATION LEVEL', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal)),
              const SizedBox(height: 6),
              Row(
                children: ['Beginner', 'Intermediate', 'Detailed'].map((lvl) {
                  final isSel = _explanationLevel == lvl;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text(lvl),
                        selected: isSel,
                        onSelected: (_) => setState(() => _explanationLevel = lvl),
                        selectedColor: AppTheme.secondaryTeal,
                        backgroundColor: const Color(0xFF0F172A),
                        labelStyle: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? Colors.black : AppTheme.textMuted,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        showCheckmark: false,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text('EXPLANATION FOCUS AREAS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _explanationFocus.keys.map((key) {
                  final isVal = _explanationFocus[key] ?? false;
                  return FilterChip(
                    label: Text(key),
                    selected: isVal,
                    onSelected: (val) => setState(() => _explanationFocus[key] = val),
                    selectedColor: AppTheme.secondaryTeal.withValues(alpha: 0.3),
                    checkmarkColor: AppTheme.secondaryTeal,
                    backgroundColor: const Color(0xFF0F172A),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11,
                      color: isVal ? Colors.white : AppTheme.textMuted,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
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
                  color: AppTheme.accentPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 5: AI TOOLS FOR SOFTWARE DEVELOPMENT',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentPurple,
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
            '"Use AI tools for software development tasks such as code generation, debugging, and code explanation."',
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
                  'To use AI tools for software development tasks such as code generation, debugging, and code explanation.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  'Objectives:',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentPurple,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                _buildObjectiveItem('1', 'Generate code using AI.'),
                _buildObjectiveItem('2', 'Identify programming errors using AI.'),
                _buildObjectiveItem('3', 'Debug existing code using AI.'),
                _buildObjectiveItem('4', 'Understand AI-generated explanations.'),
                _buildObjectiveItem('5', 'Use AI as a software development assistant.'),
                _buildObjectiveItem('6', 'Compare generated and corrected code.'),
                _buildObjectiveItem('7', 'Understand limitations of AI-generated code.'),
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
          'Theory: AI Software Development Tools',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Code Generation, Debugging & Explanation principles',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Code Generation:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12)),
                Text('AI can generate program code from natural-language requirements specifying language, inputs, outputs, and constraints.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('2. Code Debugging:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.accentPurple, fontSize: 12)),
                Text('AI analyzes source code and traceback errors to identify bugs and suggest corrected code.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('3. Code Explanation:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12)),
                Text('AI breaks down complex code into simple educational language, describing functions, variables, and control flow.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
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
          '9-step laboratory workflow',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildObjectiveItem('1', 'Select a software development task feature.'),
                _buildObjectiveItem('2', 'Select target programming language.'),
                _buildObjectiveItem('3', 'Enter requirements, error logs, or source code.'),
                _buildObjectiveItem('4', 'Inspect the exact prompt constructed for the AI.'),
                _buildObjectiveItem('5', 'Run the prompt using the real AI model.'),
                _buildObjectiveItem('6', 'Observe generated code or bug diagnosis.'),
                _buildObjectiveItem('7', 'For debugging, compare original vs corrected code.'),
                _buildObjectiveItem('8', 'For explanation, study the educational breakdown.'),
                _buildObjectiveItem('9', 'Review and test AI-generated output before production use.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Text(
              'AI LIMITATIONS & BEST PRACTICES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLimitationItem('AI-generated code may contain subtle logic errors or security flaws.'),
                _buildLimitationItem('AI may misunderstand complex, ambiguous, or incomplete requirements.'),
                _buildLimitationItem('Debugging suggestions should always be manually verified by developers.'),
                _buildLimitationItem('Generated code should be executed and tested in isolated dev environments.'),
                _buildLimitationItem('AI outputs require human oversight before deployment into production systems.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70))),
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
              hintText: 'Describe how AI helped with the selected software development task...',
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
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.accentPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'PRACTICAL 09 EXPERIMENTAL RESULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AI tools were used to perform software development tasks including code generation, debugging, and code explanation.',
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
                  'Software AI Execution Error',
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
