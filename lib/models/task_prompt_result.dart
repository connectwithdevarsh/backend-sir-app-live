/// TaskPromptResult encapsulates the result of a task-based prompt execution.
class TaskPromptResult {
  final bool success;
  final String taskType; // "summarization", "blog", "code"
  final String promptType; // "basic", "optimized"
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? error;

  TaskPromptResult({
    required this.success,
    required this.taskType,
    required this.promptType,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory TaskPromptResult.fromJson(Map<String, dynamic> json) {
    return TaskPromptResult(
      success: json['success'] ?? false,
      taskType: json['taskType'] ?? 'summarization',
      promptType: json['promptType'] ?? 'basic',
      prompt: json['prompt'] ?? '',
      output: json['output'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }

  factory TaskPromptResult.failure(String errorMessage, {String taskType = 'summarization', String promptType = 'basic', String prompt = ''}) {
    return TaskPromptResult(
      success: false,
      taskType: taskType,
      promptType: promptType,
      prompt: prompt,
      output: '',
      model: 'none',
      executionTimeMs: 0,
      error: errorMessage,
    );
  }
}
