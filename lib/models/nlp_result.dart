/// NlpResult stores the structured output from genuine local NLP processing.
class NlpResult {
  final bool success;
  final String task; // "sentiment" or "classification"
  final String label; // e.g. "POSITIVE", "NEGATIVE", "NEUTRAL" or "Education & Academics"
  final double confidence; // e.g. 0.94
  final int executionTimeMs;
  final Map<String, dynamic>? details;
  final String? errorMessage;

  const NlpResult({
    required this.success,
    required this.task,
    required this.label,
    required this.confidence,
    required this.executionTimeMs,
    this.details,
    this.errorMessage,
  });

  factory NlpResult.fromJson(Map<String, dynamic> json) {
    return NlpResult(
      success: json['success'] as bool? ?? false,
      task: json['task'] as String? ?? 'sentiment',
      label: json['label'] as String? ?? 'UNKNOWN',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      executionTimeMs: json['executionTimeMs'] as int? ?? 0,
      details: json['details'] as Map<String, dynamic>?,
      errorMessage: json['error'] as String?,
    );
  }

  factory NlpResult.error(String message) {
    return NlpResult(
      success: false,
      task: 'error',
      label: 'ERROR',
      confidence: 0.0,
      executionTimeMs: 0,
      errorMessage: message,
    );
  }
}
