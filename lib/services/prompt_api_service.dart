import 'dart:convert';
import 'dart:io';
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
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PromptResult.fromJson(data);
      } else {
        String serverError = 'HTTP ${response.statusCode}';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody.containsKey('detail')) {
            serverError = errBody['detail'].toString();
          }
        } catch (_) {}
        return PromptResult.error('Prompt engine error: $serverError');
      }
    } on SocketException {
      return PromptResult.error(
        'Backend unavailable. Please ensure the Python backend server is running at ${AppConfig.baseUrl}.',
      );
    } on http.ClientException {
      return PromptResult.error(
        'Unable to connect to AI backend service. Please check network connection.',
      );
    } on Exception catch (e) {
      return PromptResult.error(
        'Prompt execution failed: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }
}
