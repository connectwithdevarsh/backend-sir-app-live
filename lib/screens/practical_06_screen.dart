import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_example.dart';
import '../models/prompting_result.dart';
import '../services/prompting_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_input_card.dart';
import '../widgets/few_shot_examples.dart';
import '../widgets/role_configuration_card.dart';
import '../widgets/prompting_result_card.dart';
import '../widgets/prompting_comparison_card.dart';

class Practical06Screen extends StatefulWidget {
  const Practical06Screen({super.key});

  @override
  State<Practical06Screen> createState() => _Practical06ScreenState();
}

class _Practical06ScreenState extends State<Practical06Screen> {
  // Method selection: "compare", "zero_shot", "few_shot", "role_based"
  String _selectedMethod = 'compare';

  // Task controller
  final TextEditingController _taskController = TextEditingController(
    text: 'Explain Artificial Intelligence to a beginner.',
  );

  // Role-based controllers
  final TextEditingController _roleController = TextEditingController(
    text: 'You are an experienced Artificial Intelligence professor explaining concepts to Diploma IT students.',
  );
  final TextEditingController _audienceController = TextEditingController(
    text: 'First-year Diploma IT students',
  );
  final TextEditingController _toneController = TextEditingController(
    text: 'Academic, simple, and encouraging',
  );
  final TextEditingController _constraintsController = TextEditingController(
    text: 'Provide high-level structure, 2 real-world analogies, and keep it under 300 words.',
  );

  // Student observation controller
  final TextEditingController _observationController = TextEditingController(
    text: 'Zero-shot gave a broad factual summary; few-shot matched the exemplar style; role-based adapted the tone and structure to student pedagogy.',
  );

  // Few-shot examples
  List<PromptExample> _fewShotExamples = [
    PromptExample(
      input: 'Explain Machine Learning to a beginner.',
      output: 'Machine Learning is a method where computers learn patterns from data to make predictions or decisions.',
    ),
    PromptExample(
      input: 'Explain Neural Networks to a beginner.',
      output: 'Neural Networks are computational models inspired by the human brain that process information in interconnected layers.',
    ),
  ];

  // Execution states
  bool _isLoading = false;
  String _loadingStatus = '';
  String? _errorMessage;

  PromptingResult? _zeroShotResult;
  PromptingResult? _fewShotResult;
  PromptingResult? _roleBasedResult;

  // Comparison ratings
  final Map<String, String> _evaluationRatings = {
    'relevance': 'Role-Based',
    'clarity': 'Role-Based',
    'specificity': 'Few-Shot',
    'structure': 'Role-Based',
    'instruction': 'Few-Shot',
    'consistency': 'Few-Shot',
    'suitability': 'Role-Based',
  };

  // Collapsible cards state
  bool _isTheoryExpanded = false;
  bool _isProcedureExpanded = false;

  @override
  void dispose() {
    _taskController.dispose();
    _roleController.dispose();
    _audienceController.dispose();
    _toneController.dispose();
    _constraintsController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _applyTaskPreset(String presetTask) {
    setState(() {
      _taskController.text = presetTask;
      _zeroShotResult = null;
      _fewShotResult = null;
      _roleBasedResult = null;
      _errorMessage = null;

      if (presetTask.contains('cybersecurity')) {
        _fewShotExamples = [
          PromptExample(
            input: 'Explain Firewalls to a beginner.',
            output: 'A firewall is a network security barrier that monitors and filters incoming and outgoing traffic based on security rules.',
          ),
          PromptExample(
            input: 'Explain Phishing to a beginner.',
            output: 'Phishing is a fraudulent attempt to steal sensitive data by disguising as a trustworthy entity in electronic communications.',
          ),
        ];
        _roleController.text = 'You are a certified cybersecurity instructor teaching network security to engineering students.';
        _audienceController.text = 'Diploma IT students';
        _toneController.text = 'Practical, security-conscious, and direct';
        _constraintsController.text = 'Highlight defensive best practices and practical safety tips.';
      } else {
        _fewShotExamples = [
          PromptExample(
            input: 'Explain Machine Learning to a beginner.',
            output: 'Machine Learning is a method where computers learn patterns from data to make predictions or decisions.',
          ),
          PromptExample(
            input: 'Explain Neural Networks to a beginner.',
            output: 'Neural Networks are computational models inspired by the human brain that process information in interconnected layers.',
          ),
        ];
        _roleController.text = 'You are an experienced Artificial Intelligence professor explaining concepts to Diploma IT students.';
        _audienceController.text = 'First-year Diploma IT students';
        _toneController.text = 'Academic, simple, and encouraging';
        _constraintsController.text = 'Provide high-level structure, 2 real-world analogies, and keep it under 300 words.';
      }
    });
  }

  Future<void> _executePrompting() async {
    final taskText = _taskController.text.trim();
    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task description before running.', style: GoogleFonts.inter(fontSize: 12)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingStatus = 'Connecting to AI Engine...';
    });

    try {
      if (_selectedMethod == 'compare') {
        setState(() => _loadingStatus = '⟳ Running Zero-Shot, Few-Shot & Role-Based tests...');

        final res = await PromptingApiService.runPromptingTechnique(
          task: taskText,
          method: 'compare',
          examples: _fewShotExamples,
          role: _roleController.text,
          audience: _audienceController.text,
          tone: _toneController.text,
          constraints: _constraintsController.text,
        );

        if (!mounted) return;

        if (res is PromptingCompareResult && res.success) {
          setState(() {
            for (var r in res.results) {
              if (r.method == 'zero_shot') _zeroShotResult = r;
              if (r.method == 'few_shot') _fewShotResult = r;
              if (r.method == 'role_based') _roleBasedResult = r;
            }
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = (res as PromptingCompareResult).error ?? 'Failed to complete 3-way prompting comparison.';
          });
        }
      } else {
        setState(() => _loadingStatus = '⟳ Running ${_selectedMethod.toUpperCase()} inference...');

        final res = await PromptingApiService.runPromptingTechnique(
          task: taskText,
          method: _selectedMethod,
          examples: _fewShotExamples,
          role: _roleController.text,
          audience: _audienceController.text,
          tone: _toneController.text,
          constraints: _constraintsController.text,
        );

        if (!mounted) return;

        if (res is PromptingResult && res.success) {
          setState(() {
            if (_selectedMethod == 'zero_shot') _zeroShotResult = res;
            if (_selectedMethod == 'few_shot') _fewShotResult = res;
            if (_selectedMethod == 'role_based') _roleBasedResult = res;
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = (res as PromptingResult).error ?? 'Failed to execute prompting technique.';
          });
        }
      }
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
      _applyTaskPreset('Explain Artificial Intelligence to a beginner.');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 06 state reset to default.', style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'PRACTICAL 06',
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
                    color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'ZERO / FEW / ROLE-BASED',
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
              'Compare Three Prompt Engineering Techniques',
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
            // Academic Metadata Banner
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

            // Section 1: Task / Target Query Input
            Text(
              '1. TARGET TASK / QUESTION (SAME FOR ALL TECHNIQUES)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TaskInputCard(
              controller: _taskController,
              isEnabled: !_isLoading,
              onClear: () => setState(() => _taskController.clear()),
            ),

            const SizedBox(height: 8),

            // Quick Preset Task Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip('AI to Beginner', 'Explain Artificial Intelligence to a beginner.'),
                  _buildPresetChip('Cybersecurity', 'Write a short explanation of cybersecurity.'),
                  _buildPresetChip('Cloud Architecture', 'Explain Cloud Computing architecture and service models.'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Prompting Technique Selector
            Text(
              '2. SELECT PROMPTING TECHNIQUE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            _buildMethodSelector(),

            const SizedBox(height: 18),

            // Conditional Configuration Sections
            if (_selectedMethod == 'few_shot' || _selectedMethod == 'compare') ...[
              Text(
                'FEW-SHOT DEMONSTRATION EXAMPLES (PATTERNS)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              FewShotExamples(
                examples: _fewShotExamples,
                isEnabled: !_isLoading,
                onAddExample: () {
                  if (_fewShotExamples.length < 5) {
                    setState(() {
                      _fewShotExamples.add(PromptExample(input: '', output: ''));
                    });
                  }
                },
                onRemoveExample: (index) {
                  setState(() {
                    _fewShotExamples.removeAt(index);
                  });
                },
              ),
              const SizedBox(height: 18),
            ],

            if (_selectedMethod == 'role_based' || _selectedMethod == 'compare') ...[
              Text(
                'ROLE-BASED PERSONA & CONSTRAINTS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPurple,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              RoleConfigurationCard(
                roleController: _roleController,
                audienceController: _audienceController,
                toneController: _toneController,
                constraintsController: _constraintsController,
                isEnabled: !_isLoading,
              ),
              const SizedBox(height: 18),
            ],

            // Section 3: Execution Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _executePrompting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethod == 'compare'
                      ? AppTheme.primaryCyan
                      : (_selectedMethod == 'role_based'
                          ? AppTheme.accentPurple
                          : (_selectedMethod == 'few_shot'
                              ? AppTheme.secondaryTeal
                              : AppTheme.primaryCyan)),
                  foregroundColor: _selectedMethod == 'role_based' ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _selectedMethod == 'role_based' ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _loadingStatus.toUpperCase(),
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
                          Icon(
                            _selectedMethod == 'compare' ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedMethod == 'compare'
                                ? 'RUN ALL 3 PROMPTING TECHNIQUES'
                                : 'RUN ${_selectedMethod.replaceAll('_', ' ').toUpperCase()}',
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

            // Error Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_errorMessage!),
            ],

            // Section 4: Individual Result Cards
            if (_zeroShotResult != null) ...[
              const SizedBox(height: 20),
              PromptingResultCard(
                title: 'Zero-Shot Output (Direct Task)',
                result: _zeroShotResult!,
                accentColor: AppTheme.primaryCyan,
                icon: Icons.flash_on_rounded,
              ),
            ],

            if (_fewShotResult != null) ...[
              const SizedBox(height: 16),
              PromptingResultCard(
                title: 'Few-Shot Output (Exemplar Pattern)',
                result: _fewShotResult!,
                accentColor: AppTheme.secondaryTeal,
                icon: Icons.menu_book_rounded,
              ),
            ],

            if (_roleBasedResult != null) ...[
              const SizedBox(height: 16),
              PromptingResultCard(
                title: 'Role-Based Output (Persona & Audience)',
                result: _roleBasedResult!,
                accentColor: AppTheme.accentPurple,
                icon: Icons.person_pin_rounded,
              ),
            ],

            // Section 5: Comparative Matrix & Evaluation
            if (_zeroShotResult != null && _fewShotResult != null && _roleBasedResult != null) ...[
              const SizedBox(height: 24),
              PromptingComparisonCard(
                results: [_zeroShotResult!, _fewShotResult!, _roleBasedResult!],
                evaluationRatings: _evaluationRatings,
                onRatingChanged: (key, val) {
                  setState(() {
                    _evaluationRatings[key] = val;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Student Observation Notes
              _buildObservationCard(),

              const SizedBox(height: 18),

              // GTU Result Card
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

  Widget _buildPresetChip(String label, String task) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        backgroundColor: const Color(0xFF0F172A),
        side: BorderSide(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
        ),
        onPressed: !_isLoading ? () => _applyTaskPreset(task) : null,
      ),
    );
  }

  Widget _buildMethodSelector() {
    final methods = [
      {'key': 'compare', 'label': 'Compare All', 'color': AppTheme.primaryCyan, 'icon': Icons.compare_arrows_rounded},
      {'key': 'zero_shot', 'label': 'Zero-Shot', 'color': AppTheme.primaryCyan, 'icon': Icons.flash_on_rounded},
      {'key': 'few_shot', 'label': 'Few-Shot', 'color': AppTheme.secondaryTeal, 'icon': Icons.menu_book_rounded},
      {'key': 'role_based', 'label': 'Role-Based', 'color': AppTheme.accentPurple, 'icon': Icons.person_pin_rounded},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: methods.map((m) {
          final key = m['key'] as String;
          final label = m['label'] as String;
          final color = m['color'] as Color;
          final icon = m['icon'] as IconData;
          final isSelected = _selectedMethod == key;

          return Expanded(
            child: InkWell(
              onTap: !_isLoading ? () => setState(() => _selectedMethod = key) : null,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 13, color: isSelected ? color : AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
                  color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 3: PROMPT ENGINEERING FUNDAMENTALS',
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
            '"Create and test prompts using zero-shot, few-shot, and role-based prompting techniques for a given task."',
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
                  'To create and test prompts using zero-shot, few-shot, and role-based prompting techniques for a given task and compare the generated outputs.',
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
                _buildObjectiveItem('1', 'Understand zero-shot prompting principles.'),
                _buildObjectiveItem('2', 'Understand few-shot demonstration exemplars.'),
                _buildObjectiveItem('3', 'Understand role-based persona and pedagogical framing.'),
                _buildObjectiveItem('4', 'Create prompts using each of the 3 techniques for the same task.'),
                _buildObjectiveItem('5', 'Execute all prompts using a real Generative AI model.'),
                _buildObjectiveItem('6', 'Compare the generated outputs side-by-side.'),
                _buildObjectiveItem('7', 'Observe how prompt structure affects model depth, tone, and format.'),
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
          'Theory: 3 Core Prompting Paradigms',
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
                  '1. Zero-Shot Prompting',
                  'Zero-shot prompting asks the model to perform a task directly relying solely on pre-trained knowledge without providing task-specific demonstration examples.',
                  AppTheme.primaryCyan,
                ),
                _buildTheoryItem(
                  '2. Few-Shot Prompting',
                  'Few-shot prompting conditions the model by providing 2 to 5 demonstration pairs (exemplars) showing the exact expected syntax, tone, and structure before the target query.',
                  AppTheme.secondaryTeal,
                ),
                _buildTheoryItem(
                  '3. Role-Based Prompting',
                  'Role-based prompting assigns a specific persona, audience context, and communicative style to guide the model\'s depth, terminology, and perspective.',
                  AppTheme.accentPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryItem(String title, String content, Color color) {
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
              color: color,
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
      'Enter the target task or question (e.g. "Explain AI to a beginner").',
      'Select a prompting technique or choose "Compare All" to run all 3 in parallel.',
      'Configure few-shot exemplar patterns and role-based persona parameters.',
      'Press RUN to dispatch the constructed prompt(s) to the real LLM.',
      'Observe real AI responses, model names, and execution latencies.',
      'Examine the exact constructed prompts in the Prompt Inspector.',
      'Compare outputs across Relevance, Clarity, Specificity, Structure, and Tone.',
      'Record analytical observations in the GTU Laboratory Notes section.',
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

  // Observation Card
  Widget _buildObservationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, color: AppTheme.secondaryTeal, size: 18),
              const SizedBox(width: 8),
              Text(
                'STUDENT OBSERVATION NOTES',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observationController,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Record differences observed in tone, structure, and depth...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF0A0F1D),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondaryTeal),
              ),
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
            AppTheme.accentPurple.withValues(alpha: 0.15),
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
            'The given task was tested using zero-shot, few-shot, and role-based prompting techniques, and the generated outputs were compared.',
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
