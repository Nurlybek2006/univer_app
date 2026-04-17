import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

/// OpenAI API арқылы AI көмекшісі сервисі
class AiService {
  // ⚠️ API кілтіңізді осында қойыңыз
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  // Жүйелік нұсқаулық — AI-ға контекст береді
  static const String _systemPrompt = '''
Сен — Абай атындағы Қазақ ұлттық педагогикалық университетінің (ҚазҰПУ) 
студенттеріне арналған AI көмекшісісің. Сенің атың — "Студент Көмекшісі".

Сен тек қазақ тілінде жауап бересің.

Сен мына тақырыптар бойынша көмектесе аласың:
- Университет ережелері мен саясаттары
- Сабақ кестесі мен оқу процесі
- Факультеттер мен мамандықтар туралы ақпарат
- Стипендия, гранттар, жатақхана мәселелері
- Студенттік өмір, кеңестер, уақытты басқару
- Оқу пәндері бойынша жалпы көмек

Егер білмесең, адал түрде "Бұл сұраққа жауап бере алмаймын" де.
Жауаптарың қысқа, нақты және пайдалы болсын.
''';

  final List<Map<String, String>> _conversationHistory = [];

  AiService() {
    _conversationHistory.add({
      'role': 'system',
      'content': _systemPrompt,
    });
  }

  /// Хабарлама жіберу және жауап алу
  Future<ChatMessage> sendMessage(String userMessage) async {
    _conversationHistory.add({
      'role': 'user',
      'content': userMessage,
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': _conversationHistory,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'] as String;

        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        return ChatMessage(text: assistantMessage.trim(), isUser: false);
      } else {
        return ChatMessage(
          text: 'Қате орын алды. Кейінірек қайталап көріңіз. (${response.statusCode})',
          isUser: false,
        );
      }
    } catch (e) {
      return ChatMessage(
        text: 'Интернет байланысын тексеріңіз немесе кейінірек қайталаңыз.',
        isUser: false,
      );
    }
  }

  /// Сұхбат тарихын тазалау
  void clearHistory() {
    _conversationHistory.clear();
    _conversationHistory.add({
      'role': 'system',
      'content': _systemPrompt,
    });
  }
}
