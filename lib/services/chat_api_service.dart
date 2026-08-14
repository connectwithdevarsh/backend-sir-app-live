import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chat_message.dart';

/// Response payload from ChatApiService
class ChatApiResponse {
  final bool success;
  final ChatMessage message;
  final String model;
  final String provider;
  final int executionTimeMs;
  final String? error;

  ChatApiResponse({
    required this.success,
    required this.message,
    required this.model,
    required this.provider,
    required this.executionTimeMs,
    this.error,
  });
}

/// ChatApiService handles communication with the Python FastAPI backend for Practical 10 AI Chatbot.
class ChatApiService {
  static Future<Map<String, dynamic>> checkHealth() async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/health');

    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    return {
      "status": "offline",
      "provider": "none",
      "serverTime": DateTime.now().toIso8601String()
    };
  }

  static Future<ChatApiResponse> sendMessage(List<ChatMessage> messages) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/chat');

    try {
      final payload = {
        'messages': messages.map((m) => m.toJson()).toList(),
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final msgJson = data['message'] ?? {};
        final String content = msgJson['content'] ?? '';
        final String role = msgJson['role'] ?? 'assistant';

        return ChatApiResponse(
          success: data['success'] ?? true,
          message: ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: role,
            content: content,
          ),
          model: data['model'] ?? 'unknown',
          provider: data['provider'] ?? 'unknown',
          executionTimeMs: data['executionTimeMs'] ?? 0,
          error: data['error'],
        );
      } else {
        return _generateFallback(messages);
      }
    } catch (_) {
      // Offline fallback
    }

    return _generateFallback(messages);
  }

  static ChatApiResponse _generateFallback(List<ChatMessage> messages) {
    return ChatApiResponse(
      success: false,
      message: ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'AI service is temporarily unavailable. Please try again.',
      ),
      model: 'AI Service (Groq/Gemini)',
      provider: 'groq/gemini',
      executionTimeMs: 0,
    );
  }
}
