/// PracticalResult stores the structured output returned from the AI backend service.
class PracticalResult {
  final bool success;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? errorMessage;

  const PracticalResult({
    required this.success,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.errorMessage,
  });

  factory PracticalResult.fromJson(Map<String, dynamic> json) {
    return PracticalResult(
      success: json['success'] as bool? ?? false,
      output: json['output'] as String? ?? '',
      model: json['model'] as String? ?? 'gemini-2.5-flash',
      executionTimeMs: json['executionTimeMs'] as int? ?? 0,
      errorMessage: json['error'] as String?,
    );
  }

  factory PracticalResult.error(String message) {
    return PracticalResult(
      success: false,
      output: message,
      model: 'unknown',
      executionTimeMs: 0,
      errorMessage: message,
    );
  }
}
