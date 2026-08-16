/// NlpResult stores the output from real backend AI NLP processing.
class NlpResult {
  final bool success;
  final String task; // "sentiment" or "classification"
  final String label; // e.g. "POSITIVE", "NEGATIVE", "NEUTRAL" or Category Name
  final String explanation; // Real AI explanation
  final String? model; // Real AI model returned by backend (e.g. Groq/Gemini)
  final double? confidence; // Real confidence ONLY if backend returns it; null otherwise
  final int executionTimeMs; // Actual request duration measured in Flutter
  final Map<String, dynamic>? details;
  final String? errorMessage;

  const NlpResult({
    required this.success,
    required this.task,
    required this.label,
    required this.explanation,
    this.model,
    this.confidence,
    required this.executionTimeMs,
    this.details,
    this.errorMessage,
  });

  factory NlpResult.fromJson(Map<String, dynamic> json, {required int latencyMs}) {
    return NlpResult(
      success: json['success'] as bool? ?? true,
      task: json['task'] as String? ?? 'sentiment',
      label: json['label'] as String? ?? 'AI RESPONSE',
      explanation: json['explanation'] as String? ?? json['output'] as String? ?? json['response'] as String? ?? '',
      model: json['model'] as String?,
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
      executionTimeMs: latencyMs,
      details: json['details'] as Map<String, dynamic>?,
      errorMessage: json['error'] as String?,
    );
  }

  factory NlpResult.error(String message) {
    return NlpResult(
      success: false,
      task: 'error',
      label: 'ERROR',
      explanation: '',
      executionTimeMs: 0,
      errorMessage: message,
    );
  }
}
