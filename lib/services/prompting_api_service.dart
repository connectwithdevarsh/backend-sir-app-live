import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/prompt_example.dart';
import '../models/prompting_result.dart';

/// PromptingApiService communicates with the Python FastAPI backend for Practical 06
/// executing Zero-Shot, Few-Shot, Role-Based, and 3-way Compare prompting requests.
class PromptingApiService {
  static Future<dynamic> runPromptingTechnique({
    required String task,
    required String method, // "zero_shot", "few_shot", "role_based", "compare"
    List<PromptExample> examples = const [],
    String role = '',
    String audience = '',
    String tone = '',
    String constraints = '',
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/6/run');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'task': task.trim(),
              'method': method.toLowerCase().trim(),
              'examples': examples.map((e) => e.toJson()).toList(),
              'role': role.trim(),
              'audience': audience.trim(),
              'tone': tone.trim(),
              'constraints': constraints.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (method.toLowerCase() == 'compare') {
          return PromptingCompareResult.fromJson(data);
        } else {
          return PromptingResult.fromJson(data);
        }
      }
    } catch (_) {}

    return PromptingResult(
      success: false,
      method: method,
      prompt: task,
      output: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
    );
  }
}
