import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/practical_result.dart';

/// PracticalApiService manages backend API communication for live AI executions.
class PracticalApiService {
  static Future<PracticalResult> runPractical1(String prompt) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/1/run');

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
        return PracticalResult.fromJson(data);
      } else {
        return PracticalResult.error(
          'AI service is temporarily unavailable. Please try again.',
        );
      }
    } catch (e) {
      return PracticalResult.error(
        'AI service is temporarily unavailable. Please try again.',
      );
    }
  }
}
