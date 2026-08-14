import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/task_prompt_request.dart';
import '../models/task_prompt_result.dart';

/// TaskPromptApiService handles communication with the Python FastAPI backend
/// for Practical 08: Task-Based Prompt Engineering.
class TaskPromptApiService {
  static Future<TaskPromptResult> runTaskPrompt(TaskPromptRequest request) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/8/run');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TaskPromptResult.fromJson(data);
      } else {
        return _generateFallback(request);
      }
    } catch (_) {}

    return _generateFallback(request);
  }

  static TaskPromptResult _generateFallback(TaskPromptRequest req) {
    return TaskPromptResult(
      success: false,
      taskType: req.taskType,
      promptType: req.promptType,
      prompt: req.prompt.isNotEmpty ? req.prompt : "Built-in ${req.promptType} prompt",
      output: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
    );
  }
}
