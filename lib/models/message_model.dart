/// AI чат хабарламасының моделі
class ChatMessage {
  final String text;
  final bool isUser; // true = пайдаланушы, false = AI
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
