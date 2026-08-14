import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/llm_evaluation_result.dart';

/// LLMEvaluationApiService manages API communication for Practical 04 evaluation tasks.
class LLMEvaluationApiService {
  static Future<LLMEvaluationResult> evaluateQuery({
    required String category,
    required String query,
    String referenceAnswer = '',
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/4/evaluate');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'category': category.toLowerCase().trim(),
              'query': query.trim(),
              'referenceAnswer': referenceAnswer.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LLMEvaluationResult.fromJson(data);
      }
    } catch (_) {}

    return LLMEvaluationResult(
      success: false,
      category: category,
      query: query,
      response: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
      referenceAnswer: referenceAnswer,
      assistedEvaluation: AssistedEvaluation(
        hasReference: referenceAnswer.isNotEmpty,
        status: 'Service Unavailable',
        detail: 'Unable to reach backend service at ${AppConfig.baseUrl}.',
        disclaimer: 'Connection error.',
      ),
    );
  }
}
