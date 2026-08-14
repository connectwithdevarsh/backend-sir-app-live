import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/study_request.dart';
import '../models/study_result.dart';
import '../services/study_assistant_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_result_card.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/prompt_viewer_card.dart';
import '../widgets/quiz_card.dart';
import '../widgets/study_feature_selector.dart';
import '../widgets/study_plan_card.dart';

/// Practical12Screen implements GTU Practical 12:
/// "Develop an AI-based application such as a Study Assistant/Resume Generator/Blog writer/Coding assistant."
class Practical12Screen extends StatefulWidget {
  const Practical12Screen({super.key});

  @override
  State<Practical12Screen> createState() => _Practical12ScreenState();
}

class _Practical12ScreenState extends State<Practical12Screen> {
  String _selectedTask = 'explain';

  // Explain Controllers
  final TextEditingController _subjectController = TextEditingController(text: 'Artificial Intelligence');
  final TextEditingController _topicController = TextEditingController(text: 'Machine Learning');
  String _explainLevel = 'Beginner';
  String _explainStyle = 'Simple';
  bool _includeExample = true;

  // Summarize Controllers
  final TextEditingController _summaryContentController = TextEditingController(
    text:
        'Artificial Intelligence (AI) is a branch of computer science devoted to creating computing systems capable of performing cognitive tasks that traditionally require human intelligence. Machine Learning is a subset of AI enabling algorithms to learn patterns from data automatically. Generative AI algorithms create original content including text, code, audio, and images. Prompt engineering techniques optimize inputs for LLMs, and RAG grounds AI answers in external document context.',
  );
  String _summaryLength = 'Medium';
  String _summaryStyle = 'Bullet Points';

  // Quiz Controllers
  int _questionCount = 5;
  String _difficulty = 'Medium';
  final String _questionType = 'MCQ';

  // Study Plan Controllers
  final TextEditingController _subjectsListController = TextEditingController(text: 'AIPE, Python, JavaScript, IoT');
  int _availableDays = 7;
  final double _hoursPerDay = 2.0;
  String _planPriority = 'Balanced';

  // Flashcards Controllers
  int _flashcardCount = 5;

  // Execution & Output State
  bool _isLoading = false;
  StudyResult? _activeResult;
  String? _errorMessage;

  // Quiz Score State
  int _quizCorrectCount = 0;
  int _quizAnsweredCount = 0;

  // Student Observation Controller
  final TextEditingController _observationController = TextEditingController(
    text:
        'The AI Study Assistant effectively generated task-specific explanations, quizzes with answer keys, study schedules, and flashcards using dynamic prompt engineering.',
  );

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _summaryContentController.dispose();
    _subjectsListController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _handleExecuteTask() async {
    if (_isLoading) return;

    final req = StudyRequest(
      taskType: _selectedTask,
      subject: _subjectController.text.trim(),
      topic: _topicController.text.trim(),
      content: _summaryContentController.text.trim(),
      level: _explainLevel,
      style: _explainStyle,
      includeExample: _includeExample,
      summaryLength: _summaryLength,
      summaryStyle: _summaryStyle,
      questionCount: _questionCount,
      difficulty: _difficulty,
      questionType: _questionType,
      subjects: _subjectsListController.text.split(',').map((s) => s.trim()).toList(),
      days: _availableDays,
      hoursPerDay: _hoursPerDay,
      priority: _planPriority,
      cardCount: _flashcardCount,
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _activeResult = null;
      _quizCorrectCount = 0;
      _quizAnsweredCount = 0;
    });

    try {
      final res = await StudyAssistantApiService.runStudyTask(req);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (res.success) {
          _activeResult = res;
          _errorMessage = null;
        } else {
          _errorMessage = res.error ?? 'Failed to execute study task.';
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
      _selectedTask = 'explain';
      _activeResult = null;
      _errorMessage = null;
      _isLoading = false;
      _quizCorrectCount = 0;
      _quizAnsweredCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 12 state reset to default.', style: GoogleFonts.inter(fontSize: 12)),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PRACTICAL 12',
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
                    'AI STUDY ASSISTANT',
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
              'Learn Smarter with Generative AI',
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

            // Collapsible AI Limitations & Responsible AI Card
            _buildLimitationsCard(),

            const SizedBox(height: 20),

            // Feature Selection Bar
            Text(
              '1. SELECT AI STUDY TOOL',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            StudyFeatureSelector(
              selectedTask: _selectedTask,
              onTaskSelected: (task) {
                setState(() {
                  _selectedTask = task;
                  _activeResult = null;
                  _errorMessage = null;
                });
              },
            ),

            const SizedBox(height: 16),

            // Dynamic Task Input Form
            _buildTaskForm(),

            const SizedBox(height: 14),

            // Action Runner Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleExecuteTask,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Icon(_getTaskIcon(), size: 20),
                label: Text(
                  _isLoading ? 'GENERATING...' : _getTaskButtonLabel(),
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // Error Display
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_errorMessage!),
            ],

            // Execution Result Display
            if (_activeResult != null) ...[
              const SizedBox(height: 20),

              // Grounded Prompt Viewer
              PromptViewerCard(prompt: _activeResult!.prompt),

              const SizedBox(height: 14),

              // Task-Specific Output Cards
              if (_selectedTask == 'explain' || _selectedTask == 'summary')
                AiResultCard(result: _activeResult!),

              if (_selectedTask == 'quiz' && _activeResult!.quizQuestions.isNotEmpty)
                Column(
                  children: [
                    ..._activeResult!.quizQuestions.asMap().entries.map((entry) {
                      return QuizCard(
                        index: entry.key,
                        question: entry.value,
                        onAnswerSubmitted: (selected, isCorrect) {
                          setState(() {
                            _quizAnsweredCount++;
                            if (isCorrect) _quizCorrectCount++;
                          });
                        },
                      );
                    }),
                    if (_quizAnsweredCount == _activeResult!.quizQuestions.length)
                      QuizResultCard(
                        totalQuestions: _activeResult!.quizQuestions.length,
                        correctCount: _quizCorrectCount,
                        onRetake: () {
                          setState(() {
                            _quizCorrectCount = 0;
                            _quizAnsweredCount = 0;
                          });
                        },
                      ),
                  ],
                ),

              if (_selectedTask == 'study_plan' && _activeResult!.studyPlan.isNotEmpty)
                StudyPlanCard(items: _activeResult!.studyPlan),

              if (_selectedTask == 'flashcards' && _activeResult!.flashcards.isNotEmpty)
                FlashcardWidget(flashcards: _activeResult!.flashcards),

              const SizedBox(height: 16),

              // Student Observation Notes
              _buildObservationCard(),

              const SizedBox(height: 18),

              // GTU Result Certificate Card
              _buildResultCard(),
            ],

            const SizedBox(height: 20),

            // Reset Laboratory Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetLaboratory,
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

  IconData _getTaskIcon() {
    switch (_selectedTask) {
      case 'summary':
        return Icons.summarize_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'study_plan':
        return Icons.calendar_month_rounded;
      case 'flashcards':
        return Icons.style_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _getTaskButtonLabel() {
    switch (_selectedTask) {
      case 'summary':
        return '📝 GENERATE SUMMARY';
      case 'quiz':
        return '❓ GENERATE QUIZ';
      case 'study_plan':
        return '📅 CREATE STUDY PLAN';
      case 'flashcards':
        return '🗂 GENERATE FLASHCARDS';
      default:
        return '✨ EXPLAIN TOPIC';
    }
  }

  Widget _buildTaskForm() {
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
          if (_selectedTask == 'explain') ...[
            _buildTextField('SUBJECT', _subjectController, 'e.g. Artificial Intelligence'),
            const SizedBox(height: 10),
            _buildTextField('TOPIC', _topicController, 'e.g. Machine Learning'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'EXPLANATION LEVEL',
                    _explainLevel,
                    ['Beginner', 'Intermediate', 'Advanced'],
                    (v) => setState(() => _explainLevel = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    'EXPLANATION STYLE',
                    _explainStyle,
                    ['Simple', 'Detailed', 'Exam-Oriented', 'Real-World'],
                    (v) => setState(() => _explainStyle = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('INCLUDE REAL-WORLD EXAMPLE:', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white)),
                const Spacer(),
                Switch(
                  value: _includeExample,
                  activeThumbColor: AppTheme.primaryCyan,
                  onChanged: (v) => setState(() => _includeExample = v),
                ),
              ],
            ),
          ],

          if (_selectedTask == 'summary') ...[
            Text('STUDY MATERIAL CONTENT', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _summaryContentController,
              maxLines: 4,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Paste study material text here...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'SUMMARY LENGTH',
                    _summaryLength,
                    ['Short', 'Medium', 'Detailed'],
                    (v) => setState(() => _summaryLength = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    'SUMMARY STYLE',
                    _summaryStyle,
                    ['Bullet Points', 'Paragraph', 'Exam Revision'],
                    (v) => setState(() => _summaryStyle = v!),
                  ),
                ),
              ],
            ),
          ],

          if (_selectedTask == 'quiz') ...[
            _buildTextField('SUBJECT', _subjectController, 'e.g. Artificial Intelligence'),
            const SizedBox(height: 10),
            _buildTextField('TOPIC', _topicController, 'e.g. Prompt Engineering'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'QUESTION COUNT',
                    '$_questionCount',
                    ['5', '10', '15'],
                    (v) => setState(() => _questionCount = int.parse(v!)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    'DIFFICULTY',
                    _difficulty,
                    ['Easy', 'Medium', 'Hard', 'Mixed'],
                    (v) => setState(() => _difficulty = v!),
                  ),
                ),
              ],
            ),
          ],

          if (_selectedTask == 'study_plan') ...[
            _buildTextField('SUBJECTS (COMMA SEPARATED)', _subjectsListController, 'AIPE, Python, JavaScript, IoT'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'AVAILABLE DAYS',
                    '$_availableDays',
                    ['3', '5', '7', '14'],
                    (v) => setState(() => _availableDays = int.parse(v!)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    'PRIORITY FOCUS',
                    _planPriority,
                    ['Weak Topics', 'Balanced', 'Revision Focus'],
                    (v) => setState(() => _planPriority = v!),
                  ),
                ),
              ],
            ),
          ],

          if (_selectedTask == 'flashcards') ...[
            _buildTextField('SUBJECT', _subjectController, 'e.g. Artificial Intelligence'),
            const SizedBox(height: 10),
            _buildTextField('TOPIC', _topicController, 'e.g. Key Concepts'),
            const SizedBox(height: 10),
            _buildDropdown(
              'NUMBER OF CARDS',
              '$_flashcardCount',
              ['5', '10', '15'],
              (v) => setState(() => _flashcardCount = int.parse(v!)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
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
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 5: AI TOOLS FOR SOFTWARE DEVELOPMENT',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTeal,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'AI Study Suite',
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
            '"Develop an AI-based application such as a Study Assistant/Resume Generator/Blog writer/Coding assistant."',
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
          '8 educational laboratory goals',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aim:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12.5)),
                Text('To develop an AI-based Study Assistant that uses Generative AI to support students in learning, revision, summarization, quiz generation, and study planning.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
                const SizedBox(height: 10),
                Text('Objectives:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12.5)),
                const SizedBox(height: 4),
                _buildBullet('1', 'Use AI for educational assistance.'),
                _buildBullet('2', 'Generate explanations for technical concepts.'),
                _buildBullet('3', 'Summarize study material.'),
                _buildBullet('4', 'Generate practice questions with answer keys.'),
                _buildBullet('5', 'Create personalized study plans.'),
                _buildBullet('6', 'Generate flashcards for revision.'),
                _buildBullet('7', 'Design task-specific AI prompts.'),
                _buildBullet('8', 'Understand the benefits and limitations of AI in education.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String num, String text) {
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
          'Theory: AI Study Assistant',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Educational applications, benefits, & limitations',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What is an AI Study Assistant?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12)),
                Text('An AI-powered educational application helping students understand, revise, and organize learning material through concept explanation, summarization, quiz generation, study planning, and revision support.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
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
          'Procedure & Laboratory Steps',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '12-step study assistant experiment workflow',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBullet('1', 'Start the Python FastAPI backend.'),
                _buildBullet('2', 'Configure the AI API credentials.'),
                _buildBullet('3', 'Open Practical 12 AI Study Assistant.'),
                _buildBullet('4', 'Select a study tool (Explain, Summarize, Quiz, Plan, Flashcards).'),
                _buildBullet('5', 'Enter topic or study material details.'),
                _buildBullet('6', 'Review the dynamically constructed prompt.'),
                _buildBullet('7', 'Execute the AI request.'),
                _buildBullet('8', 'Observe the AI-generated result.'),
                _buildBullet('9', 'Test interactive quizzes and flip flashcards.'),
                _buildBullet('10', 'Use copy features if required.'),
                _buildBullet('11', 'Test another study feature.'),
                _buildBullet('12', 'Verify dynamic generation across tasks.'),
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
            const Icon(Icons.security_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Text(
              'AI LIMITATIONS & RESPONSIBLE USE',
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
                _buildLimitationItem('AI may produce incorrect or oversimplified explanations; verify critical academic facts against trusted textbooks.'),
                _buildLimitationItem('Generated practice quizzes are learning aids and should be checked against official GTU course materials.'),
                _buildLimitationItem('Use AI as a study companion to enhance understanding, not as a replacement for independent study.'),
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
              hintText: 'Describe how the AI Study Assistant helped in the selected learning task...',
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
                'PRACTICAL 12 EXPERIMENTAL RESULT',
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
            'An AI-based Study Assistant was developed using Generative AI to support concept explanation, summarization, quiz generation, study planning, and flashcard-based revision.',
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
                  'Study Task Execution Error',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5,
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
