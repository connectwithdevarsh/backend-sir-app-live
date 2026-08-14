/// SoftwareAiResult encapsulates response from AI Software Assistant API.
class SoftwareAiResult {
  final bool success;
  final String taskType; // "code_generation", "debugging", "code_explanation"
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final String? error;

  SoftwareAiResult({
    required this.success,
    required this.taskType,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory SoftwareAiResult.fromJson(Map<String, dynamic> json) {
    return SoftwareAiResult(
      success: json['success'] ?? false,
      taskType: json['taskType'] ?? 'code_generation',
      prompt: json['prompt'] ?? '',
      output: json['output'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }

  factory SoftwareAiResult.failure(String errorMessage, {String taskType = 'code_generation', String prompt = ''}) {
    return SoftwareAiResult(
      success: false,
      taskType: taskType,
      prompt: prompt,
      output: '',
      model: 'none',
      executionTimeMs: 0,
      error: errorMessage,
    );
  }

  /// Extracts code block enclosed inside ```python ... ``` or markdown fence
  String extractCodeBlock(String defaultLang) {
    if (output.contains('```')) {
      final parts = output.split('```');
      if (parts.length >= 2) {
        String codePart = parts[1].trim();
        // Remove leading language identifier like "python\n" or "dart\n"
        if (codePart.contains('\n')) {
          final firstLine = codePart.split('\n').first.trim().toLowerCase();
          if (['python', 'javascript', 'dart', 'java', 'c', 'cpp', 'html', 'sql'].contains(firstLine)) {
            codePart = codePart.substring(firstLine.length).trim();
          }
        }
        return codePart;
      }
    }
    return output;
  }
}
