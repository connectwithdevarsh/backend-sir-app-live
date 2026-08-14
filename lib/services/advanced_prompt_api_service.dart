import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chain_result.dart';
import '../models/chain_step.dart';
import '../models/reasoning_result.dart';

/// AdvancedPromptApiService handles communication with the Python FastAPI backend
/// for Practical 07: Structured Reasoning (Chain-of-Thought style) and Prompt Chaining.
class AdvancedPromptApiService {
  static Future<dynamic> executeAdvancedPrompting({
    required String task,
    required String method, // "structured_reasoning", "prompt_chaining", "compare"
    List<ChainStep> steps = const [],
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/7/run');
    final String cleanTask = task.trim();
    final String cleanMethod = method.toLowerCase().trim();

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'task': cleanTask,
              'method': cleanMethod,
              'steps': steps.map((s) => s.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (cleanMethod == 'structured_reasoning') {
          return ReasoningResult.fromJson(data);
        } else if (cleanMethod == 'prompt_chaining') {
          return ChainResult.fromJson(data);
        } else {
          return AdvancedPromptCompareResult.fromJson(data);
        }
      } else {
        return ReasoningResult(
          success: false,
          prompt: cleanTask,
          method: cleanMethod,
          output: 'AI service is temporarily unavailable. Please try again.',
          model: 'AI Service (Groq/Gemini)',
          executionTimeMs: 0,
        );
      }
    } catch (_) {
      return ReasoningResult(
        success: false,
        prompt: cleanTask,
        method: cleanMethod,
        output: 'AI service is temporarily unavailable. Please try again.',
        model: 'AI Service (Groq/Gemini)',
        executionTimeMs: 0,
      );
    }
  }
}
