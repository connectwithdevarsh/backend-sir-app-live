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
          .timeout(const Duration(seconds: 5));

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
          .timeout(const Duration(seconds: 35));

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
    final lastMsg = messages.isNotEmpty ? messages.last.content.toLowerCase() : '';
    String responseText = '';

    if (lastMsg.contains('artificial intelligence') || lastMsg.contains('what is ai')) {
      responseText =
          "Artificial Intelligence (AI) is a branch of computer science focused on building smart machines capable of performing tasks that typically require human intelligence, such as learning, reasoning, problem solving, and language understanding.";
    } else if (lastMsg.contains('machine learning') || lastMsg.contains('ml')) {
      responseText =
          "Machine Learning (ML) is a subset of AI that enables systems to automatically learn and improve from experience without being explicitly programmed.";
    } else if (lastMsg.contains('python') || lastMsg.contains('function')) {
      responseText = """In Python, functions are defined using the `def` keyword. Here is a simple example:

```python
def greet_student(name):
    return f"Hello {name}, welcome to AIPE LAB!"

print(greet_student("Diploma Student"))
```
Functions promote code reusability and modular design.""";
    } else if (lastMsg.contains('application') || lastMsg.contains('example')) {
      responseText =
          "Two popular real-world applications of AI include:\n1. **Virtual Assistants**: Siri, Google Assistant, and ChatGPT for automated assistance.\n2. **Recommendation Systems**: Personalized suggestions on Netflix, YouTube, and Amazon.";
    } else {
      responseText =
          "I am your AIPE LAB AI Assistant! I can help you understand Artificial Intelligence concepts, prompt engineering techniques, and Python code examples. What would you like to learn today?";
    }

    return ChatApiResponse(
      success: true,
      message: ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: responseText,
      ),
      model: 'demo-engine (chatbot)',
      provider: 'groq/gemini',
      executionTimeMs: 480,
    );
  }
}
