import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/nlp_result.dart';

/// NlpApiService manages API communication with live Render backend
/// for Practical 02 NLP Sentiment Analysis and Text Classification,
/// and handles silent app startup backend warm-up.
class NlpApiService {
  static bool _hasWarmedUp = false;

  /// Silently sends a background warm-up request to wake the Render backend on app launch.
  static Future<void> warmupBackend() async {
    if (_hasWarmedUp) return;
    _hasWarmedUp = true;

    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/health');
    try {
      // Background non-blocking warm-up call
      await http.get(url, headers: {'Accept': 'application/json'}).timeout(
        const Duration(seconds: 15),
      );
    } catch (_) {
      // Warm-up failure is silent and non-blocking
    }
  }

  /// Sends NLP Sentiment or Classification request to live Render backend with real latency timing and retry logic.
  static Future<NlpResult> analyzeText({
    required String text,
    required String task,
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/2/analyze');
    final startTime = DateTime.now();

    const maxAttempts = 2;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'text': text.trim(),
                'task': task.toLowerCase().trim(),
              }),
            )
            .timeout(const Duration(seconds: 60));

        final latencyMs = DateTime.now().difference(startTime).inMilliseconds;

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return NlpResult.fromJson(data, latencyMs: latencyMs);
        } else if (response.statusCode >= 500 && attempt < maxAttempts) {
          // Retry once on server 5xx cold start error
          await Future.delayed(const Duration(milliseconds: 1500));
          continue;
        } else {
          return NlpResult.error(
            'API Error (HTTP ${response.statusCode}): ${response.body}',
          );
        }
      } catch (e) {
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 1500));
          continue;
        }
        return NlpResult.error(
          'Connection Error: Unable to reach AI service ($e). Please check internet connection.',
        );
      }
    }

    return NlpResult.error('AI service temporarily unavailable. Please try again.');
  }
}
