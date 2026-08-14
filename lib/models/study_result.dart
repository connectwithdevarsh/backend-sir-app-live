import 'quiz_question.dart';
import 'flashcard.dart';
import 'study_plan_item.dart';

/// StudyResult encapsulates execution output for Practical 12 AI Study Assistant.
class StudyResult {
  final bool success;
  final String taskType;
  final String prompt;
  final String result;
  final List<QuizQuestion> quizQuestions;
  final List<Flashcard> flashcards;
  final List<StudyPlanItem> studyPlan;
  final String model;
  final int executionTimeMs;
  final String? error;

  StudyResult({
    required this.success,
    required this.taskType,
    required this.prompt,
    required this.result,
    this.quizQuestions = const [],
    this.flashcards = const [],
    this.studyPlan = const [],
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory StudyResult.fromJson(Map<String, dynamic> json) {
    var parsed = json['parsedData'] as Map<String, dynamic>? ?? {};

    List<QuizQuestion> qList = [];
    if (parsed.containsKey('questions') && parsed['questions'] is List) {
      qList = (parsed['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
    }

    List<Flashcard> fcList = [];
    if (parsed.containsKey('flashcards') && parsed['flashcards'] is List) {
      fcList = (parsed['flashcards'] as List)
          .map((fc) => Flashcard.fromJson(fc))
          .toList();
    }

    List<StudyPlanItem> spList = [];
    if (parsed.containsKey('plan') && parsed['plan'] is List) {
      spList = (parsed['plan'] as List)
          .map((sp) => StudyPlanItem.fromJson(sp))
          .toList();
    }

    return StudyResult(
      success: json['success'] ?? true,
      taskType: json['taskType'] ?? 'explain',
      prompt: json['prompt'] ?? '',
      result: json['result'] ?? '',
      quizQuestions: qList,
      flashcards: fcList,
      studyPlan: spList,
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }
}
