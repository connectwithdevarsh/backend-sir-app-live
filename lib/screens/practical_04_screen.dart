import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/llm_evaluation_result.dart';
import '../services/llm_evaluation_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/query_category_selector.dart';
import '../widgets/query_input_card.dart';
import '../widgets/reference_answer_card.dart';
import '../widgets/llm_response_card.dart';
import '../widgets/evaluation_card.dart';
import '../widgets/hallucination_observation_card.dart';

class Practical04Screen extends StatefulWidget {
  const Practical04Screen({super.key});

  @override
  State<Practical04Screen> createState() => _Practical04ScreenState();
}

class _Practical04ScreenState extends State<Practical04Screen> {
  // State
  String _selectedCategory = 'factual'; // 'factual', 'logical', 'ambiguous'
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();

  bool _isLoading = false;
  LLMEvaluationResult? _evaluationResult;
  String? _errorMessage;

  // Student Evaluation State
  String? _selectedAccuracy;
  final List<String> _selectedAmbiguityChecks = [];

  // Collapsible Section State
  bool _isTheoryExpanded = false;
  bool _isProcedureExpanded = false;

  @override
  void initState() {
    super.initState();
    _applyDefaultCategoryPreset('factual');
  }

  @override
  void dispose() {
    _queryController.dispose();
    _referenceController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _applyDefaultCategoryPreset(String category) {
    setState(() {
      _selectedCategory = category;
      _evaluationResult = null;
      _errorMessage = null;
      _selectedAccuracy = null;
      _selectedAmbiguityChecks.clear();

      switch (category.toLowerCase()) {
        case 'logical':
          _queryController.text =
              'If all mammals are animals and all dogs are mammals, are all dogs animals? Explain briefly.';
          _referenceController.text = 'Yes, under the stated premises.';
          _observationController.text =
              'Observed clear deductive reasoning using the transitive property.';
          break;
        case 'ambiguous':
          _queryController.text = 'Tell me about Java.';
          _referenceController.text =
              'Ambiguous query; Java may refer to the programming language, Indonesian island, or coffee.';
          _observationController.text =
              'Observed whether the model asked for clarification or assumed the programming language.';
          break;
        case 'factual':
        default:
          _queryController.text = 'What is the capital of France?';
          _referenceController.text = 'Paris';
          _observationController.text =
              'Observed factual correctness against known geographic data.';
          break;
      }
    });
  }

  Future<void> _runLLMTest() async {
    final queryText = _queryController.text.trim();
    if (queryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a query before running the test.',
            style: GoogleFonts.inter(fontSize: 12),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _evaluationResult = null;
    });

    final result = await LLMEvaluationApiService.evaluateQuery(
      category: _selectedCategory,
      query: queryText,
      referenceAnswer: _referenceController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        _evaluationResult = result;
        _errorMessage = null;
      } else {
        _errorMessage = result.error ?? 'An unexpected error occurred during LLM evaluation.';
      }
    });
  }

  void _resetLaboratory() {
    setState(() {
      _applyDefaultCategoryPreset(_selectedCategory);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Practical 04 inputs and evaluation reset.',
          style: GoogleFonts.inter(fontSize: 12),
        ),
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
                  'PRACTICAL 04',
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
                    color: AppTheme.accentPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'LLM EVALUATION',
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
              'Testing Factual, Logical & Ambiguous Queries',
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

            // Section 1: Query Category Selector
            Text(
              '1. SELECT QUERY CATEGORY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            QueryCategorySelector(
              selectedCategory: _selectedCategory,
              isEnabled: !_isLoading,
              onCategoryChanged: (cat) => _applyDefaultCategoryPreset(cat),
            ),

            const SizedBox(height: 16),

            // Section 2: Query Input Card
            QueryInputCard(
              controller: _queryController,
              category: _selectedCategory,
              isEnabled: !_isLoading,
              onPresetSelected: (ref) {
                setState(() {
                  _referenceController.text = ref;
                });
              },
            ),

            const SizedBox(height: 14),

            // Section 3: Reference Answer Card (Optional)
            ReferenceAnswerCard(
              controller: _referenceController,
              isEnabled: !_isLoading,
            ),

            const SizedBox(height: 18),

            // Action Buttons: RUN & RESET
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runLLMTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCyan,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'TESTING LLM...',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
                                'RUN LLM TEST',
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
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _resetLaboratory,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'RESET',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Error Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 18),
              _buildErrorCard(_errorMessage!),
            ],

            // Real LLM Output & Evaluation Sections
            if (_evaluationResult != null) ...[
              const SizedBox(height: 24),

              // LLM Model Response Card
              LLMResponseCard(result: _evaluationResult!),

              const SizedBox(height: 16),

              // Student Evaluation Card
              EvaluationCard(
                category: _selectedCategory,
                selectedAccuracy: _selectedAccuracy,
                onAccuracySelected: (acc) {
                  setState(() {
                    _selectedAccuracy = acc;
                  });
                },
                selectedAmbiguityChecks: _selectedAmbiguityChecks,
                onAmbiguityCheckToggled: (checkKey) {
                  setState(() {
                    if (_selectedAmbiguityChecks.contains(checkKey)) {
                      _selectedAmbiguityChecks.remove(checkKey);
                    } else {
                      _selectedAmbiguityChecks.add(checkKey);
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // Hallucination Checklist & Student Notes
              HallucinationObservationCard(
                observationController: _observationController,
                isEnabled: true,
              ),

              const SizedBox(height: 18),

              // Final GTU Result / Conclusion Banner
              _buildResultCard(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Academic Header Widget
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
                  'UNIT 2: LLMs & PROMPT ENGINEERING',
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
              color: AppTheme.accentPurple,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"Evaluate the capabilities and limitations of LLMs by testing factual, logical, and ambiguous queries and identifying hallucinations."',
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
                  'To evaluate the capabilities and limitations of a Large Language Model by testing factual, logical, and ambiguous queries and identifying possible hallucinations.',
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
                _buildObjectiveItem('1', 'Test factual questions with an LLM.'),
                _buildObjectiveItem('2', 'Test logical questions with an LLM.'),
                _buildObjectiveItem('3', 'Test ambiguous questions with an LLM.'),
                _buildObjectiveItem('4', 'Observe the generated responses.'),
                _buildObjectiveItem('5', 'Compare responses with known/reference information where appropriate.'),
                _buildObjectiveItem('6', 'Identify possible hallucinations or unsupported claims.'),
                _buildObjectiveItem('7', 'Understand that LLM responses may not always be reliable.'),
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
          'Theory: LLM Capabilities & Hallucinations',
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
                  'What is an LLM?',
                  'A Large Language Model is an AI model trained on large amounts of text to generate, understand, and complete human language based on statistical token probabilities.',
                ),
                _buildTheoryItem(
                  'What is a Factual Query?',
                  'A question whose answer can be objectively verified against known real-world information and databases (e.g., capitals, historical dates, physical constants).',
                ),
                _buildTheoryItem(
                  'What is a Logical Query?',
                  'A question requiring multi-step deductive reasoning, condition evaluation, or mathematical relationships (e.g., syllogisms, transitive orderings).',
                ),
                _buildTheoryItem(
                  'What is an Ambiguous Query?',
                  'A query that has multiple valid interpretations or lacks sufficient context (e.g., "Tell me about Java"). High-capability models should recognize ambiguity and request clarification.',
                ),
                _buildTheoryItem(
                  'What is Hallucination?',
                  'A generated statement that appears plausible and confident but is unsupported, factually incorrect, or fabricated by the model.',
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
      'Select a query category (Factual, Logical, or Ambiguous).',
      'Enter a query or select an interactive template.',
      'Optionally supply reference information / expected behavior.',
      'Press ▶ RUN LLM TEST to send the query to the live LLM.',
      'Observe the actual model response, latency, and model name.',
      'Compare the response against reference ground truth.',
      'Perform hallucination check and record student observation notes.',
      'Select the student accuracy classification for empirical recording.',
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
                  'LLM Evaluation Error',
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
            AppTheme.accentPurple.withValues(alpha: 0.15),
            AppTheme.primaryCyan.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded, color: AppTheme.accentPurple, size: 20),
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
            'The LLM was evaluated on a ${_selectedCategory.toUpperCase()} query. The response was analyzed for factual precision, reasoning validity, ambiguity handling, and absence of hallucinations.',
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
