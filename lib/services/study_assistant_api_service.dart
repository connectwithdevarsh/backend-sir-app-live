import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/study_request.dart';
import '../models/study_result.dart';

/// StudyAssistantApiService handles communication with Python FastAPI backend for Practical 12.
class StudyAssistantApiService {
  static Future<StudyResult> runStudyTask(StudyRequest request) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/study-assistant');

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
        return StudyResult.fromJson(data);
      } else {
        return _generateFallback(request);
      }
    } catch (_) {
      // Offline fallback
    }

    return _generateFallback(request);
  }

  static StudyResult _generateFallback(StudyRequest request) {
    return StudyResult(
      success: false,
      taskType: request.taskType,
      prompt: "Built-in ${request.taskType} prompt",
      result: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
    );
  }
}
