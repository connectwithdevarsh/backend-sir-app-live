import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/software_ai_request.dart';
import '../models/software_ai_result.dart';

/// SoftwareAiApiService handles communication with the Python FastAPI backend
/// for Practical 09: AI Software Development Assistant.
class SoftwareAiApiService {
  static Future<SoftwareAiResult> runSoftwareTask(SoftwareAiRequest request) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/9/run');

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
        return SoftwareAiResult.fromJson(data);
      } else {
        return _generateFallback(request);
      }
    } catch (_) {
      // Offline fallback
    }

    return _generateFallback(request);
  }

  static SoftwareAiResult _generateFallback(SoftwareAiRequest req) {
    return SoftwareAiResult(
      success: false,
      taskType: req.taskType,
      prompt: "Built-in ${req.taskType} prompt",
      output: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
    );
  }
}
