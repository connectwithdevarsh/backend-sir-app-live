/// ChatMessage represents a single message in the AI Chatbot conversation.
class ChatMessage {
  final String id;
  final String role; // "user" or "assistant"
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role.toLowerCase() == 'user';
  bool get isAssistant => role.toLowerCase() == 'assistant' || role.toLowerCase() == 'ai';

  Map<String, dynamic> toJson() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': content.trim(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
