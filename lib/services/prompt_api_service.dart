import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/prompt_example.dart';
import '../models/prompt_result.dart';

/// PromptApiService manages API communication for Zero-Shot, Few-Shot, and Compare prompting executions.
class PromptApiService {
  static Future<PromptResult> runPrompting({
    required String task,
    required String method,
    List<PromptExample> examples = const [],
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/3/run');

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
              'method': method.toLowerCase(),
              'examples': examples.map((e) => e.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PromptResult.fromJson(data);
      } else {
        return PromptResult.error('AI service is temporarily unavailable. Please try again.');
      }
    } catch (_) {
      return PromptResult.error(
        'AI service is temporarily unavailable. Please try again.',
      );
    }
  }
}
