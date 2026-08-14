import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/prompt_execution_result.dart';

/// PromptRefinementApiService manages communication with the Python FastAPI backend
/// for executing Basic and Refined prompts against real Generative AI models.
class PromptRefinementApiService {
  static Future<PromptExecutionResult> runPrompt({
    required String prompt,
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/5/run');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'prompt': prompt.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PromptExecutionResult.fromJson(data);
      }
    } catch (_) {}

    return PromptExecutionResult(
      success: false,
      prompt: prompt,
      output: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
    );
  }
}
