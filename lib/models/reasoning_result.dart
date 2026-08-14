/// ReasoningResult models the output of a Structured Reasoning (Chain-of-Thought style) execution.
class ReasoningResult {
  final bool success;
  final String method;
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? error;

  ReasoningResult({
    required this.success,
    required this.method,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory ReasoningResult.fromJson(Map<String, dynamic> json) {
    return ReasoningResult(
      success: json['success'] ?? false,
      method: json['method'] ?? 'structured_reasoning',
      prompt: json['prompt'] ?? '',
      output: json['output'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }

  factory ReasoningResult.failure(String errorMessage, {String prompt = ''}) {
    return ReasoningResult(
      success: false,
      method: 'structured_reasoning',
      prompt: prompt,
      output: '',
      model: 'none',
      executionTimeMs: 0,
      error: errorMessage,
    );
  }

  /// Extracts the portion after "FINAL ANSWER:" if present in output
  String get finalAnswer {
    if (output.contains('FINAL ANSWER:')) {
      final parts = output.split('FINAL ANSWER:');
      return parts.last.trim();
    }
    return output;
  }

  /// Extracts intermediate steps prior to "FINAL ANSWER:"
  String get intermediateSteps {
    if (output.contains('FINAL ANSWER:')) {
      final parts = output.split('FINAL ANSWER:');
      return parts.first.trim();
    }
    return output;
  }
}
