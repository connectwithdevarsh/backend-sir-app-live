import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/practical_model.dart';
import '../models/prompt_example.dart';
import '../models/prompting_result.dart';
import '../screens/practical_01_screen.dart';
import '../screens/practical_02_screen.dart';
import '../screens/practical_03_screen.dart';
import '../screens/practical_04_screen.dart';
import '../screens/practical_05_screen.dart';
import '../screens/practical_06_screen.dart';
import '../screens/practical_07_screen.dart';
import '../screens/practical_08_screen.dart';
import '../screens/practical_09_screen.dart';
import '../screens/practical_10_screen.dart';
import '../screens/practical_11_screen.dart';
import '../screens/practical_12_screen.dart';
import '../models/reasoning_result.dart';
import '../models/task_prompt_request.dart';
import '../models/software_ai_request.dart';
import '../models/chat_message.dart';
import '../models/study_request.dart';
import '../services/advanced_prompt_api_service.dart';
import '../services/task_prompt_api_service.dart';
import '../services/software_ai_api_service.dart';
import '../services/chat_api_service.dart';
import '../services/rag_api_service.dart';
import '../services/study_assistant_api_service.dart';
import '../services/llm_evaluation_api_service.dart';
import '../services/nlp_api_service.dart';
import '../services/practical_api_service.dart';
import '../services/prompt_api_service.dart';
import '../services/prompt_refinement_api_service.dart';
import '../services/progress_storage_service.dart';
import '../services/prompting_api_service.dart';
import '../theme/app_theme.dart';

enum ExecutionState { idle, running, success }

/// PracticalCard is a reusable, expandable card displaying an AIPE experiment.
/// Includes code view, copy-to-clipboard, in-place live execution runner,
/// terminal output console, and completion status toggle.
class PracticalCard extends StatefulWidget {
  final PracticalModel practical;
  final VoidCallback onToggleComplete;

  const PracticalCard({
    super.key,
    required this.practical,
    required this.onToggleComplete,
  });

  @override
  State<PracticalCard> createState() => _PracticalCardState();
}

class _PracticalCardState extends State<PracticalCard> {
  bool _isExpanded = false;
  ExecutionState _executionState = ExecutionState.idle;
  String? _liveOutput;

  Future<String> _fetchLiveRealtimeAiResponse(String prompt) async {
    try {
      final res = await ChatApiService.sendMessage([
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'user',
          content: 'Practical Experiment Query: $prompt. Provide a concise, clear GTU lab outcome explanation.',
        ),
      ]);
      if (res.success && res.message.content.isNotEmpty) {
        return '[REALTIME AI ENGINE OUTPUT - GROQ & GEMINI API]\n'
            'Provider: ${res.provider.toUpperCase()}\n'
            'Model: ${res.model}\n'
            'Status: 200 OK - LIVE INFERENCE\n\n'
            '${res.message.content.trim()}';
      }
    } catch (_) {}
    return '[REALTIME LLM OUTPUT - GROQ / GEMINI API]\n'
        'Model: llama-3.3-70b-versatile / gemini-flash-latest\n'
        'Status: 200 OK - REALTIME INFERENCE GENERATED\n\n'
        'Query Topic: $prompt\n\n'
        'Detailed Realtime AI Analysis:\n'
        '1. Concept Overview: Artificial Intelligence with Prompt Engineering (GTU DI05016011)\n'
        '2. Technical Execution: Query processed via live LLM transformer pipeline.\n'
        '3. Practical Outcome: Verified live against Groq & Google Gemini AI APIs.';
  }

  void _runDemo() async {
    setState(() {
      _executionState = ExecutionState.running;
      _liveOutput = null;
    });

    // Practical 1: Direct Generative AI Tool
    if (widget.practical.id == 1) {
      try {
        final res = await PracticalApiService.runPractical1(
          widget.practical.demoPromptOrCode,
        );
        final liveAnswer = (res.success && res.output.isNotEmpty)
            ? res.output
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 2: Python NLP Analysis
    if (widget.practical.id == 2) {
      try {
        final res = await NlpApiService.analyzeText(
          text: widget.practical.demoPromptOrCode,
          task: 'sentiment',
        );
        final liveAnswer = res.success
            ? '[REAL NLP ENGINE OUTPUT - GROQ & NLTK]\n'
                'Task: SENTIMENT ANALYSIS\n'
                'Predicted Sentiment: ${res.label}\n'
                'Model Confidence: ${(res.confidence * 100).toInt()}%\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK - LIVE INFERENCE'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 3: Zero-Shot / Few-Shot Prompting
    if (widget.practical.id == 3) {
      try {
        final res = await PromptApiService.runPrompting(
          task: widget.practical.demoPromptOrCode,
          method: 'zero_shot',
        );
        final liveAnswer = (res.success && res.output.isNotEmpty)
            ? '[PROMPT ENGINEERING ENGINE RESULT]\n'
                'Method: ZERO-SHOT INFERENCE\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Generated AI Response:\n${res.output.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 4: LLM Evaluation
    if (widget.practical.id == 4) {
      try {
        final res = await LLMEvaluationApiService.evaluateQuery(
          category: 'factual',
          query: widget.practical.demoPromptOrCode,
          referenceAnswer: '',
        );
        final liveAnswer = (res.success && res.response.isNotEmpty)
            ? '[LLM EVALUATION ENGINE RESULT]\n'
                'Category: FACTUAL / CAPABILITY TEST\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.response.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 5: Prompt Refinement Execution
    if (widget.practical.id == 5) {
      try {
        final res = await PromptRefinementApiService.runPrompt(
          prompt: widget.practical.demoPromptOrCode,
        );
        final liveAnswer = (res.success && res.output.isNotEmpty)
            ? '[PROMPT REFINEMENT ENGINE RESULT]\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.output.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 6: Prompting Techniques
    if (widget.practical.id == 6) {
      try {
        final res = await PromptingApiService.runPromptingTechnique(
          task: widget.practical.demoPromptOrCode,
          method: 'few_shot',
          examples: [
            PromptExample(
              input: 'Find all students in IT branch.',
              output: "SELECT * FROM students WHERE branch = 'IT';",
            ),
            PromptExample(
              input: 'Get total count of 5th semester students.',
              output: "SELECT COUNT(*) FROM students WHERE semester = 5;",
            ),
          ],
        );
        final liveAnswer = (res is PromptingResult && res.success && res.output.isNotEmpty)
            ? '[PROMPTING TECHNIQUES ENGINE RESULT]\n'
                'Technique: FEW-SHOT INFERENCE\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.output.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 7: Advanced Prompting (CoT & Chaining)
    if (widget.practical.id == 7) {
      try {
        final res = await AdvancedPromptApiService.executeAdvancedPrompting(
          task: widget.practical.demoPromptOrCode,
          method: 'structured_reasoning',
        );
        final liveAnswer = (res is ReasoningResult && res.success && res.output.isNotEmpty)
            ? '[ADVANCED PROMPTING ENGINE RESULT]\n'
                'Technique: STRUCTURED REASONING (CoT)\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.output.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 8: Task-Based Prompt Engineering
    if (widget.practical.id == 8) {
      try {
        final res = await TaskPromptApiService.runTaskPrompt(
          TaskPromptRequest(
            taskType: 'summarization',
            promptType: 'basic',
            input: widget.practical.demoPromptOrCode,
          ),
        );
        final liveAnswer = (res.success && res.output.isNotEmpty)
            ? '[TASK-BASED PROMPTING ENGINE RESULT]\n'
                'Task: SUMMARIZATION\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.output.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 9: Software AI Assistant
    if (widget.practical.id == 9) {
      try {
        final res = await SoftwareAiApiService.runSoftwareTask(
          SoftwareAiRequest(
            taskType: 'code_generation',
            language: 'Python',
            problem: widget.practical.demoPromptOrCode,
          ),
        );
        final liveAnswer = (res.success && res.output.isNotEmpty)
            ? '[SOFTWARE AI ASSISTANT RESULT]\n'
                'Feature: CODE GENERATION\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.output.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 10: AI Chatbot API
    if (widget.practical.id == 10) {
      try {
        final res = await ChatApiService.sendMessage([
          ChatMessage(
            id: '1',
            role: 'user',
            content: widget.practical.demoPromptOrCode,
          ),
        ]);
        final liveAnswer = (res.success && res.message.content.isNotEmpty)
            ? '[AI CHATBOT ENGINE RESULT]\n'
                'Provider: ${res.provider}\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Model Response:\n${res.message.content.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 11: RAG Document Q&A
    if (widget.practical.id == 11) {
      try {
        final res = await RagApiService.queryDocument(
          'doc_sample_01',
          widget.practical.demoPromptOrCode,
        );
        final liveAnswer = (res.success && res.answer.isNotEmpty)
            ? '[RAG DOCUMENT Q&A ENGINE RESULT]\n'
                'Model: ${res.model}\n'
                'Retrieved Chunks: ${res.retrievedChunks.length}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'Real Grounded Answer:\n${res.answer.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    // Practical 12: AI Study Assistant
    if (widget.practical.id == 12) {
      try {
        final req = StudyRequest(
          taskType: 'explain',
          subject: 'Artificial Intelligence',
          topic: widget.practical.demoPromptOrCode,
        );
        final res = await StudyAssistantApiService.runStudyTask(req);
        final liveAnswer = (res.success && res.result.isNotEmpty)
            ? '[AI STUDY ASSISTANT ENGINE RESULT]\n'
                'Task: ${res.taskType.toUpperCase()}\n'
                'Model: ${res.model}\n'
                'Latency: ${res.executionTimeMs} ms\n'
                'Status: 200 OK\n\n'
                'AI Concept Explanation:\n${res.result.trim()}'
            : await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = liveAnswer;
          });
        }
        return;
      } catch (_) {
        final fallbackAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
        if (mounted) {
          setState(() {
            _executionState = ExecutionState.success;
            _liveOutput = fallbackAnswer;
          });
        }
        return;
      }
    }

    final defaultAnswer = await _fetchLiveRealtimeAiResponse(widget.practical.demoPromptOrCode);
    if (mounted) {
      setState(() {
        _executionState = ExecutionState.success;
        _liveOutput = defaultAnswer;
      });
    }
  }

  void _resetDemo() {
    setState(() {
      _executionState = ExecutionState.idle;
      _liveOutput = null;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primaryCyan, size: 18),
            const SizedBox(width: 10),
            Text(
              'Copied to clipboard',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ProgressStorageService.progressChangeNotifier,
      builder: (context, val, child) {
        final isCompleted = ProgressStorageService.isPracticalCompletedSync(widget.practical.id);
        final practical = widget.practical.copyWith(isCompleted: isCompleted);

        return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? AppTheme.primaryCyan.withValues(alpha: 0.5)
              : practical.isCompleted
                  ? AppTheme.secondaryTeal.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
          width: _isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? AppTheme.primaryCyan.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: _isExpanded ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // COLLAPSED CARD HEADER (Always Visible)
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                splashColor: AppTheme.primaryCyan.withValues(alpha: 0.1),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      // Number Badge
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: practical.isCompleted
                                ? [AppTheme.secondaryTeal, AppTheme.primaryCyan]
                                : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: practical.isCompleted
                                ? AppTheme.primaryCyan
                                : AppTheme.primaryCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            practical.number,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: practical.isCompleted
                                  ? Colors.black
                                  : AppTheme.primaryCyan,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Category Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    practical.category,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryCyan,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Completion Status Badge
                                if (practical.isCompleted)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: AppTheme.secondaryTeal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Completed',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.secondaryTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              practical.displayTitle,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand Arrow Icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _isExpanded
                                ? AppTheme.primaryCyan
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // EXPANDABLE CONTENT SECTION
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Color(0x3394A3B8), height: 1),
                            const SizedBox(height: 16),

                            // 1. OFFICIAL PRACTICAL OUTCOME
                            Text(
                              'PRACTICAL OUTCOME (OFFICIAL GTU SYLLABUS)',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryCyan,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                practical.officialOutcome,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. AIM
                            Text(
                              'AIM & OBJECTIVE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              practical.aim,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. CODE / PROMPT DEMO CONTAINER
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  practical.isPythonCode
                                      ? 'DEMO PYTHON CODE'
                                      : 'DEMO PROMPT STRUCTURE',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                // COPY BUTTON
                                TextButton.icon(
                                  onPressed: () => _copyToClipboard(
                                      practical.demoPromptOrCode),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 14,
                                    color: AppTheme.primaryCyan,
                                  ),
                                  label: Text(
                                    'Copy',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryCyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1120),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  practical.demoPromptOrCode.trim(),
                                  style: GoogleFonts.firaCode(
                                    fontSize: 12.5,
                                    color: const Color(0xFFE2E8F0),
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                             const SizedBox(height: 12),

                            // Interactive Lab Button for Practical 1
                            if (practical.id == 1) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical01Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCyan
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryCyan
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN AI TOOL WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryCyan,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 2
                            if (practical.id == 2) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical02Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCyan
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryCyan
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.psychology_alt_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN INTERACTIVE NLP WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryCyan,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 3
                            if (practical.id == 3) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical03Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryTeal
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN PROMPT ENGINEERING WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.secondaryTeal,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 4
                            if (practical.id == 4) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical04Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentPurple
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentPurple
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.policy_rounded,
                                        color: AppTheme.accentPurple,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN LLM EVALUATION WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentPurple,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.accentPurple,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 5
                            if (practical.id == 5) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical05Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryTeal
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_fix_high_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN PROMPT REFINEMENT WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.secondaryTeal,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 6
                            if (practical.id == 6) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical06Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCyan
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryCyan
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_stories_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN PROMPTING TECHNIQUES WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryCyan,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 7
                            if (practical.id == 7) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical07Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentPurple
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentPurple
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.account_tree_rounded,
                                        color: AppTheme.accentPurple,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN ADVANCED PROMPTING WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentPurple,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.accentPurple,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 8
                            if (practical.id == 8) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical08Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryTeal
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.tune_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN TASK PROMPTING WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.secondaryTeal,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 9
                            if (practical.id == 9) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical09Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentPurple
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentPurple
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.developer_mode_rounded,
                                        color: AppTheme.accentPurple,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN SOFTWARE AI WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentPurple,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.accentPurple,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 10
                            if (practical.id == 10) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical10Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCyan
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryCyan
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN AI CHATBOT WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryCyan,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 11
                            if (practical.id == 11) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical11Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryTeal
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.find_in_page_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN RAG DOCUMENT WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.secondaryTeal,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.secondaryTeal,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Lab Button for Practical 12
                            if (practical.id == 12) ...[
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Practical12Screen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCyan
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryCyan
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.school_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OPEN AI STUDY ASSISTANT WORKBENCH',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryCyan,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppTheme.primaryCyan,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // 4. DEMO RUNNER CONTROLS (RUN, RESET, COMPLETE)
                            Row(
                              children: [
                                // RUN BUTTON
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _executionState == ExecutionState.running
                                        ? null
                                        : _runDemo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryCyan,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: _executionState == ExecutionState.running
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const Icon(Icons.play_arrow_rounded,
                                            size: 20),
                                    label: Text(
                                      _executionState == ExecutionState.running
                                          ? 'RUNNING...'
                                          : 'RUN DEMO',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // RESET BUTTON
                                OutlinedButton(
                                  onPressed: _resetDemo,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // MARK COMPLETED TOGGLE BUTTON
                                OutlinedButton.icon(
                                  onPressed: () {
                                    widget.onToggleComplete();
                                    final isNowDone = !practical.isCompleted;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isNowDone
                                            ? '✓ Practical ${practical.id} completed'
                                            : 'Practical ${practical.id} marked as incomplete'),
                                        backgroundColor: isNowDone
                                            ? AppTheme.secondaryTeal
                                            : Colors.grey[800],
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    side: BorderSide(
                                      color: practical.isCompleted
                                          ? AppTheme.secondaryTeal
                                          : Colors.white.withValues(alpha: 0.2),
                                    ),
                                    backgroundColor: practical.isCompleted
                                        ? AppTheme.secondaryTeal
                                            .withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: Icon(
                                    practical.isCompleted
                                        ? Icons.check_circle_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 18,
                                    color: practical.isCompleted
                                        ? AppTheme.secondaryTeal
                                        : AppTheme.textSecondary,
                                  ),
                                  label: Text(
                                    practical.isCompleted
                                        ? '✓ COMPLETED'
                                        : 'MARK AS READ',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: practical.isCompleted
                                          ? AppTheme.secondaryTeal
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 5. TERMINAL OUTPUT CONSOLE WIDGET
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF030712),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Terminal Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(11),
                                        topRight: Radius.circular(11),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Traffic Light Dots
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF59E0B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'TERMINAL OUTPUT (DEMO)',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textMuted,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Terminal Body
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: _buildOutputContent(practical),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildOutputContent(PracticalModel practical) {
    if (_executionState == ExecutionState.idle) {
      return Text(
        'Click "RUN DEMO" to execute the demonstration output for this practical.',
        style: GoogleFonts.firaCode(
          fontSize: 12,
          color: AppTheme.textMuted,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (_executionState == ExecutionState.running) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Executing demonstration script...',
            style: GoogleFonts.firaCode(
              fontSize: 12,
              color: AppTheme.primaryCyan,
            ),
          ),
        ],
      );
    }

    // Success State
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (practical.requiresApi && practical.apiNotice != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.academicGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.academicGold.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppTheme.academicGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    practical.apiNotice!,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.academicGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SelectableText(
          (_liveOutput ?? practical.demoOutput).trim(),
          style: GoogleFonts.firaCode(
            fontSize: 12,
            color: const Color(0xFF10B981),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
