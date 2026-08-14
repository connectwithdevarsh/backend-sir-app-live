import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chain_result.dart';
import '../models/chain_step.dart';
import '../models/reasoning_result.dart';
import '../services/advanced_prompt_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chain_step_editor.dart';
import '../widgets/chain_step_result.dart';
import '../widgets/reasoning_result_card.dart';
import '../widgets/task_input_card.dart';
import '../widgets/technique_comparison_card.dart';
import '../widgets/technique_selector.dart';

/// Practical07Screen implements GTU Practical 07:
/// "Apply advanced prompting techniques such as chain-of-thought and prompt chaining to solve multi-step problems."
class Practical07Screen extends StatefulWidget {
  const Practical07Screen({super.key});

  @override
  State<Practical07Screen> createState() => _Practical07ScreenState();
}

class _Practical07ScreenState extends State<Practical07Screen> {
  // Selected technique method: "compare", "structured_reasoning", "prompt_chaining"
  String _selectedMethod = 'compare';

  // Task type preset: "mathematical", "analytical", "text_processing", "custom"
  String _selectedTaskType = 'mathematical';

  // Multi-step task text controller
  final TextEditingController _taskController = TextEditingController(
    text:
        'Calculate the total cost of 5 notebooks at ₹80 each and 3 pens at ₹20 each. Apply a 10% discount and calculate the final amount.',
  );

  // Student observation controller
  final TextEditingController _observationController = TextEditingController(
    text:
        'Structured reasoning solved the multi-step calculation within a single request using explicit intermediate steps. Prompt chaining divided the reasoning into 4 distinct input/output steps, making step verification easier.',
  );

  // Prompt chain steps configuration (Default 4 steps)
  List<ChainStep> _chainSteps = [
    ChainStep(
      name: 'Step 1 — Understand & Extract',
      prompt:
          'Extract the important values, rates, discounts, and target requirements from the problem: {{original_task}}',
    ),
    ChainStep(
      name: 'Step 2 — Solve & Calculate',
      prompt:
          'Using the extracted information from the previous step:\n{{previous_output}}\n\nPerform the required calculations step by step.',
    ),
    ChainStep(
      name: 'Step 3 — Verify Calculations',
      prompt:
          'Verify the calculations from the previous step for accuracy:\n{{previous_output}}',
    ),
    ChainStep(
      name: 'Step 4 — Finalize Answer',
      prompt:
          'Generate a concise final answer statement based on the verified result:\n{{previous_output}}',
    ),
  ];

  // Execution states
  bool _isLoading = false;
  String _loadingStatus = '';
  String? _errorMessage;

  ReasoningResult? _structuredResult;
  ChainResult? _chainResult;

  // Student evaluation ratings
  final Map<String, String> _evaluationRatings = {
    'clarity': 'Chain Preferred',
    'quality': 'Similar',
    'structure': 'CoT Preferred',
    'error_detection': 'Chain Preferred',
    'completion': 'Similar',
  };

  @override
  void dispose() {
    _taskController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _applyTaskPreset(String type) {
    setState(() {
      _selectedTaskType = type;
      _structuredResult = null;
      _chainResult = null;
      _errorMessage = null;

      if (type == 'mathematical') {
        _taskController.text =
            'Calculate the total cost of 5 notebooks at ₹80 each and 3 pens at ₹20 each. Apply a 10% discount and calculate the final amount.';
        _chainSteps = [
          ChainStep(
            name: 'Step 1 — Extract Values',
            prompt:
                'Extract all numerical values, item quantities, unit prices, and discount percentages from: {{original_task}}',
          ),
          ChainStep(
            name: 'Step 2 — Compute Subtotal',
            prompt:
                'Calculate the subtotal cost for each item group and the total subtotal based on:\n{{previous_output}}',
          ),
          ChainStep(
            name: 'Step 3 — Apply Discount',
            prompt:
                'Calculate the 10% discount amount and subtract it from subtotal based on:\n{{previous_output}}',
          ),
          ChainStep(
            name: 'Step 4 — Final Statement',
            prompt:
                'Generate the final answer statement based on:\n{{previous_output}}',
          ),
        ];
      } else if (type == 'analytical') {
        _taskController.text =
            'A college wants to improve student attendance. Identify 3 possible reasons for low attendance, suggest one solution for each reason, and prioritize the solutions.';
        _chainSteps = [
          ChainStep(
            name: 'Step 1 — Identify Causes',
            prompt:
                'Identify 3 primary causes of low student attendance for: {{original_task}}',
          ),
          ChainStep(
            name: 'Step 2 — Propose Solutions',
            prompt:
                'Propose one practical solution for each identified cause:\n{{previous_output}}',
          ),
          ChainStep(
            name: 'Step 3 — Prioritize Solutions',
            prompt:
                'Prioritize the proposed solutions based on feasibility and immediate impact:\n{{previous_output}}',
          ),
        ];
      } else if (type == 'text_processing') {
        _taskController.text =
            'Read the following paragraph: "Prompt engineering structures text inputs to guide generative AI models effectively. It involves understanding model context windows, instruction formatting, and iterative prompt design." Identify the main idea, extract 3 key points, and create a 2-sentence summary.';
        _chainSteps = [
          ChainStep(
            name: 'Step 1 — Extract Main Idea',
            prompt:
                'Identify the central main idea of the paragraph: {{original_task}}',
          ),
          ChainStep(
            name: 'Step 2 — Extract Key Points',
            prompt:
                'Extract 3 key technical points based on:\n{{previous_output}}',
          ),
          ChainStep(
            name: 'Step 3 — Create Summary',
            prompt:
                'Create a concise 2-sentence summary based on:\n{{previous_output}}',
          ),
        ];
      }
    });
  }

  Future<void> _executeAdvancedPrompting() async {
    final taskText = _taskController.text.trim();
    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a multi-step task before running.',
              style: GoogleFonts.inter(fontSize: 12)),
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
        setState(() => _loadingStatus = '⟳ Running CoT & Sequential Prompt Chain...');

        final res = await AdvancedPromptApiService.executeAdvancedPrompting(
          task: taskText,
          method: 'compare',
          steps: _chainSteps,
        );

        if (!mounted) return;

        if (res is AdvancedPromptCompareResult && res.success) {
          setState(() {
            _structuredResult = res.structuredResult;
            _chainResult = res.chainResult;
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = (res as AdvancedPromptCompareResult).error ??
                'Failed to execute 2-way technique comparison.';
          });
        }
      } else if (_selectedMethod == 'structured_reasoning') {
        setState(() => _loadingStatus = '⟳ Running Structured Reasoning (CoT)...');

        final res = await AdvancedPromptApiService.executeAdvancedPrompting(
          task: taskText,
          method: 'structured_reasoning',
        );

        if (!mounted) return;

        if (res is ReasoningResult && res.success) {
          setState(() {
            _structuredResult = res;
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = (res as ReasoningResult).error ??
                'Failed to execute structured reasoning.';
          });
        }
      } else {
        // prompt_chaining
        setState(() => _loadingStatus = '⟳ Running ${_chainSteps.length}-Step Prompt Chain...');

        final res = await AdvancedPromptApiService.executeAdvancedPrompting(
          task: taskText,
          method: 'prompt_chaining',
          steps: _chainSteps,
        );

        if (!mounted) return;

        if (res is ChainResult && res.success) {
          setState(() {
            _chainResult = res;
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = (res as ChainResult).error ??
                'Failed to execute prompt chaining.';
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
      _applyTaskPreset('mathematical');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 07 state reset to default.',
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
                  'PRACTICAL 07',
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
                    color: AppTheme.accentViolet.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppTheme.accentViolet.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'ADVANCED PROMPTING',
                    style: GoogleFonts.firaCode(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentViolet,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Chain-of-Thought & Prompt Chaining',
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

            const SizedBox(height: 20),

            // Section 1: Task Type Presets & Multi-step Task Input
            Text(
              '1. MULTI-STEP PROBLEM / TASK INPUT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // Preset Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip('mathematical', 'MATHEMATICAL'),
                  _buildPresetChip('analytical', 'ANALYTICAL'),
                  _buildPresetChip('text_processing', 'TEXT PROCESSING'),
                  _buildPresetChip('custom', 'CUSTOM'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Task Input Editor
            TaskInputCard(
              controller: _taskController,
              isEnabled: !_isLoading,
              onClear: () => setState(() => _taskController.clear()),
            ),

            const SizedBox(height: 20),

            // Section 2: Technique Selector
            Text(
              '2. SELECT ADVANCED TECHNIQUE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            TechniqueSelector(
              selectedMethod: _selectedMethod,
              onMethodChanged: (method) =>
                  setState(() => _selectedMethod = method),
              isEnabled: !_isLoading,
            ),

            const SizedBox(height: 18),

            // Section 3: Prompt Chain Step Configuration (Shown for prompt_chaining or compare)
            if (_selectedMethod == 'prompt_chaining' ||
                _selectedMethod == 'compare') ...[
              ChainStepEditor(
                steps: _chainSteps,
                isEnabled: !_isLoading,
                onAddStep: () {
                  if (_chainSteps.length < 6) {
                    setState(() {
                      final num = _chainSteps.length + 1;
                      _chainSteps.add(
                        ChainStep(
                          name: 'Step $num — Subtask',
                          prompt:
                              'Process {{previous_output}} for step $num.',
                        ),
                      );
                    });
                  }
                },
                onRemoveStep: (index) {
                  if (_chainSteps.length > 2) {
                    setState(() {
                      _chainSteps.removeAt(index);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
            ],

            // Section 4: Execution Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _executeAdvancedPrompting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethod == 'compare'
                      ? AppTheme.primaryCyan
                      : (_selectedMethod == 'prompt_chaining'
                          ? AppTheme.accentViolet
                          : AppTheme.secondaryTeal),
                  foregroundColor: Colors.black,
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
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
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
                            _selectedMethod == 'compare'
                                ? Icons.bolt_rounded
                                : Icons.play_arrow_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedMethod == 'compare'
                                ? 'RUN ALL ADVANCED TECHNIQUES'
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

            // Section 5: Structured Reasoning Result Card
            if (_structuredResult != null) ...[
              const SizedBox(height: 20),
              ReasoningResultCard(result: _structuredResult!),
            ],

            // Section 6: Prompt Chain Result Card
            if (_chainResult != null) ...[
              const SizedBox(height: 20),
              ChainStepResult(result: _chainResult!),
            ],

            // Section 7: Technique Comparison Card & Observations
            if (_structuredResult != null && _chainResult != null) ...[
              const SizedBox(height: 24),
              TechniqueComparisonCard(
                structuredResult: _structuredResult!,
                chainResult: _chainResult!,
                evaluationRatings: _evaluationRatings,
                onRatingChanged: (key, val) {
                  setState(() {
                    _evaluationRatings[key] = val;
                  });
                },
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

  Widget _buildPresetChip(String type, String label) {
    final isSel = _selectedTaskType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSel,
        onSelected: (_) => _applyTaskPreset(type),
        selectedColor: AppTheme.primaryCyan,
        backgroundColor: const Color(0xFF0F172A),
        side: BorderSide(
            color: isSel ? AppTheme.primaryCyan : Colors.white.withValues(alpha: 0.1)),
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
          color: isSel ? Colors.black : AppTheme.textMuted,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
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
                  color: AppTheme.accentViolet.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 4: ADVANCED PROMPTING TECHNIQUES',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentViolet,
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
            '"Apply advanced prompting techniques such as chain-of-thought and prompt chaining to solve multi-step problems."',
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
                  'To apply advanced prompting techniques such as chain-of-thought and prompt chaining to solve multi-step problems and evaluate intermediate outputs.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  'Objectives:',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentViolet,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                _buildObjectiveItem('1', 'Understand advanced prompting principles.'),
                _buildObjectiveItem('2', 'Understand multi-step problem solving.'),
                _buildObjectiveItem('3', 'Use structured reasoning prompts.'),
                _buildObjectiveItem('4', 'Use prompt chaining.'),
                _buildObjectiveItem('5', 'Break a complex task into smaller steps.'),
                _buildObjectiveItem('6', 'Observe intermediate outputs.'),
                _buildObjectiveItem('7', 'Generate a final answer from multiple steps.'),
                _buildObjectiveItem('8', 'Compare direct and chained approaches.'),
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
          'Theory: CoT & Prompt Chaining',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Concepts, rules, and architecture',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Structured Reasoning (Chain-of-Thought Style):',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12.5)),
                const SizedBox(height: 4),
                Text(
                  'Chain-of-thought prompting encourages the model to approach a complex problem through a sequence of intermediate steps before producing the final answer.\nNote: We request concise task-relevant intermediate steps without asking for hidden developer reasoning.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text('2. Prompt Chaining:',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.accentViolet, fontSize: 12.5)),
                const SizedBox(height: 4),
                Text(
                  'Prompt chaining divides a larger task into multiple smaller prompts. The output of Step N becomes the input to Step N+1:\nPrompt 1 → Output 1 → Prompt 2 → Output 2 → Final Answer.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
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
          'Step-by-step laboratory workflow',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildObjectiveItem('1', 'Enter a multi-step problem into the input box.'),
                _buildObjectiveItem('2', 'Select an advanced prompting technique.'),
                _buildObjectiveItem('3', 'Generate the required structured prompt or chain.'),
                _buildObjectiveItem('4', 'Execute the prompt using the configured Generative AI model.'),
                _buildObjectiveItem('5', 'Observe intermediate results generated by the model.'),
                _buildObjectiveItem('6', 'For prompt chaining, pass each output to the next step.'),
                _buildObjectiveItem('7', 'Compare the single-request CoT approach with multi-step chaining.'),
                _buildObjectiveItem('8', 'Record student observations and conclusions.'),
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
              hintText: 'Describe how breaking the task into steps affected the result...',
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
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'PRACTICAL 07 EXPERIMENTAL RESULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Both Chain-of-Thought (Structured Reasoning) and Prompt Chaining techniques were successfully executed and compared on multi-step problems.',
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
