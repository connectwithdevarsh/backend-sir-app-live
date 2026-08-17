/// PracticalResult stores the structured output returned from the AI backend service.
class PracticalResult {
  final bool success;
  final String output;
  final String model;
  final String? provider;
  final int executionTimeMs;
  final String? errorMessage;

  const PracticalResult({
    required this.success,
    required this.output,
    required this.model,
    this.provider,
    required this.executionTimeMs,
    this.errorMessage,
  });

  factory PracticalResult.fromJson(Map<String, dynamic> json) {
    final bool isSuccess = json['success'] as bool? ?? false;
    final String rawOutput = json['output'] as String? ?? json['response'] as String? ?? '';
    final String rawModel = json['model'] as String? ?? 'groq/gemini/nvidia';
    final String? rawProvider = json['provider'] as String?;
    final int latency = json['executionTimeMs'] as int? ?? 0;

    String? errorStr;
    if (!isSuccess) {
      final errObj = json['error'];
      if (errObj is Map<String, dynamic>) {
        if (errObj['code'] == 'AI_CAPACITY_TEMPORARY') {
          errorStr = 'AI service is currently busy. Please try again shortly.';
        } else {
          errorStr = errObj['message']?.toString() ?? 'AI provider temporarily unavailable.';
        }
      } else {
        errorStr = errObj?.toString() ?? 'AI request failed.';
      }
    }

    return PracticalResult(
      success: isSuccess,
      output: isSuccess ? rawOutput : (errorStr ?? rawOutput),
      model: rawModel,
      provider: rawProvider,
      executionTimeMs: latency,
      errorMessage: errorStr,
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
