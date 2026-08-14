/// SoftwareAiRequest encapsulates payload parameters for POST /api/practical/9/run
class SoftwareAiRequest {
  final String taskType; // "code_generation", "debugging", "code_explanation"
  final String language;
  final String problem;
  final String requirements;
  final String code;
  final String error;
  final String expectedBehavior;
  final String explanationLevel;
  final List<String> focus;

  SoftwareAiRequest({
    required this.taskType,
    this.language = 'Python',
    this.problem = '',
    this.requirements = '',
    this.code = '',
    this.error = '',
    this.expectedBehavior = '',
    this.explanationLevel = 'Beginner',
    this.focus = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'taskType': taskType.trim(),
      'language': language.trim(),
      'problem': problem.trim(),
      'requirements': requirements.trim(),
      'code': code.trim(),
      'error': error.trim(),
      'expectedBehavior': expectedBehavior.trim(),
      'explanationLevel': explanationLevel.trim(),
      'focus': focus,
    };
  }
}
