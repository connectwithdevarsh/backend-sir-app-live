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
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PracticalResult.fromJson(data);
      } else {
        String serverError = 'HTTP ${response.statusCode}';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody.containsKey('detail')) {
            serverError = errBody['detail'].toString();
          }
        } catch (_) {}
        return PracticalResult.error(
          'Unable to connect to AI backend service ($serverError). Please ensure backend is running.',
        );
      }
    } catch (e) {
      return PracticalResult.error(
        'Unable to connect to AI backend service at ${AppConfig.baseUrl}. Please start backend server with: python -m uvicorn main:app --reload --port 8000',
      );
    }
  }
}
