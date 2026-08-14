class AssistedEvaluation {
  final bool hasReference;
  final String status;
  final String detail;
  final String disclaimer;

  AssistedEvaluation({
    required this.hasReference,
    required this.status,
    required this.detail,
    required this.disclaimer,
  });

  factory AssistedEvaluation.fromJson(Map<String, dynamic> json) {
    return AssistedEvaluation(
      hasReference: json['hasReference'] ?? false,
      status: json['status'] ?? 'No evaluation available',
      detail: json['detail'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'hasReference': hasReference,
        'status': status,
        'detail': detail,
        'disclaimer': disclaimer,
      };
}

class LLMEvaluationResult {
  final bool success;
  final String category;
  final String query;
  final String response;
  final String model;
  final int executionTimeMs;
  final String referenceAnswer;
  final AssistedEvaluation? assistedEvaluation;
  final String? error;

  LLMEvaluationResult({
    required this.success,
    required this.category,
    required this.query,
    required this.response,
    required this.model,
    required this.executionTimeMs,
    this.referenceAnswer = '',
    this.assistedEvaluation,
    this.error,
  });

  factory LLMEvaluationResult.fromJson(Map<String, dynamic> json) {
    return LLMEvaluationResult(
      success: json['success'] ?? false,
      category: json['category'] ?? 'factual',
      query: json['query'] ?? '',
      response: json['response'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      referenceAnswer: json['referenceAnswer'] ?? '',
      assistedEvaluation: json['assistedEvaluation'] != null
          ? AssistedEvaluation.fromJson(json['assistedEvaluation'])
          : null,
      error: json['error'],
    );
  }

  factory LLMEvaluationResult.failure(String errorMessage, {String category = 'factual', String query = ''}) {
    return LLMEvaluationResult(
      success: false,
      category: category,
      query: query,
      response: '',
      model: 'unknown',
      executionTimeMs: 0,
      error: errorMessage,
    );
  }
}
