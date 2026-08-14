/// PromptingResult models the real Generative AI output,
/// method, prompt, execution latency, and error state for Practical 06.
class PromptingResult {
  final bool success;
  final String method; // 'zero_shot', 'few_shot', 'role_based', 'compare'
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? error;

  PromptingResult({
    required this.success,
    required this.method,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory PromptingResult.fromJson(Map<String, dynamic> json) {
    return PromptingResult(
      success: json['success'] ?? false,
      method: json['method'] ?? 'zero_shot',
      prompt: json['prompt'] ?? '',
      output: json['output'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }

  factory PromptingResult.failure(String errorMessage, {String method = 'zero_shot', String prompt = ''}) {
    return PromptingResult(
      success: false,
      method: method,
      prompt: prompt,
      output: '',
      model: 'unknown',
      executionTimeMs: 0,
      error: errorMessage,
    );
  }
}

class PromptingCompareResult {
  final bool success;
  final String task;
  final List<PromptingResult> results;
  final String? error;

  PromptingCompareResult({
    required this.success,
    required this.task,
    required this.results,
    this.error,
  });

  factory PromptingCompareResult.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List? ?? [];
    return PromptingCompareResult(
      success: json['success'] ?? false,
      task: json['task'] ?? '',
      results: rawResults.map((r) => PromptingResult.fromJson(r as Map<String, dynamic>)).toList(),
      error: json['error'],
    );
  }

  factory PromptingCompareResult.failure(String errorMessage, {String task = ''}) {
    return PromptingCompareResult(
      success: false,
      task: task,
      results: [],
      error: errorMessage,
    );
  }
}
