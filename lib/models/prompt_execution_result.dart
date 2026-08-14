/// PromptExecutionResult models the actual Generative AI output,
/// model name, execution latency, and error state for Practical 05.
class PromptExecutionResult {
  final bool success;
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? error;

  PromptExecutionResult({
    required this.success,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory PromptExecutionResult.fromJson(Map<String, dynamic> json) {
    return PromptExecutionResult(
      success: json['success'] ?? false,
      prompt: json['prompt'] ?? '',
      output: json['output'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }

  factory PromptExecutionResult.failure(String errorMessage, {String prompt = ''}) {
    return PromptExecutionResult(
      success: false,
      prompt: prompt,
      output: '',
      model: 'unknown',
      executionTimeMs: 0,
      error: errorMessage,
    );
  }
}
