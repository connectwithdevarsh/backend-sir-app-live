/// PromptResult holds the execution output for Zero-Shot or Few-Shot prompting.
class PromptResult {
  final bool success;
  final String method; // "zero_shot", "few_shot", or "compare"
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? error;
  final List<PromptResult>? subResults; // for compare mode

  const PromptResult({
    required this.success,
    required this.method,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.error,
    this.subResults,
  });

  factory PromptResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('results') && json['results'] is List) {
      final List rawList = json['results'] as List;
      final sub = rawList.map((e) => PromptResult.fromJson(e as Map<String, dynamic>)).toList();
      return PromptResult(
        success: json['success'] as bool? ?? false,
        method: json['method'] as String? ?? 'compare',
        prompt: '',
        output: '',
        model: '',
        executionTimeMs: 0,
        subResults: sub,
        error: json['error'] as String?,
      );
    }

    return PromptResult(
      success: json['success'] as bool? ?? false,
      method: json['method'] as String? ?? 'zero_shot',
      prompt: json['prompt'] as String? ?? '',
      output: json['output'] as String? ?? '',
      model: json['model'] as String? ?? 'AI Model',
      executionTimeMs: json['executionTimeMs'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }

  factory PromptResult.error(String message) {
    return PromptResult(
      success: false,
      method: 'error',
      prompt: '',
      output: '',
      model: 'none',
      executionTimeMs: 0,
      error: message,
    );
  }
}
