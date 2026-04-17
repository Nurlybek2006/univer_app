import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/ai_service.dart';

/// AI Көмекші беті — чат интерфейсі
class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final AiService _aiService = AiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Сәлемдесу хабарламасы
    _messages.add(ChatMessage(
      text: 'Сәлеметсіз бе! 👋 Мен — Абай ҚазҰПУ студенттеріне арналған '
          'AI көмекшімін. Маған кез келген сұрақ қоюға болады:\n\n'
          '• Университет ережелері\n'
          '• Сабақ кестесі\n'
          '• Стипендия мәселелері\n'
          '• Студенттік өмір\n\n'
          'Сұрағыңызды жазыңыз!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Хабарлама жіберу
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await _aiService.sendMessage(text);

    setState(() {
      _messages.add(response);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Көмекші'),
        actions: [
          // Сұхбатты тазалау батырмасы
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Сұхбатты тазалау',
            onPressed: () {
              setState(() {
                _messages.clear();
                _aiService.clearHistory();
                _messages.add(ChatMessage(
                  text: 'Сұхбат тазаланды. Жаңа сұрақ қойыңыз!',
                  isUser: false,
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Хабарламалар тізімі
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator(colorScheme);
                }
                return _buildMessageBubble(_messages[index], colorScheme);
              },
            ),
          ),

          // Жылдам сұрақтар (тек хабарламалар аз болғанда)
          if (_messages.length <= 1)
            _buildQuickActions(colorScheme),

          // Хабарлама жіберу аймағы
          _buildInputArea(colorScheme),
        ],
      ),
    );
  }

  /// Хабарлама көпіршігі
  Widget _buildMessageBubble(ChatMessage message, ColorScheme colorScheme) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// Теру индикаторы (AI жауап жазып жатыр)
  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Жауап жазылуда...',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Жылдам сұрақ батырмалары
  Widget _buildQuickActions(ColorScheme colorScheme) {
    final quickQuestions = [
      'Стипендия алу шарттары қандай?',
      'Сессия қашан басталады?',
      'Жатақханаға қалай орналасуға болады?',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: quickQuestions.map((q) {
          return ActionChip(
            label: Text(q, style: const TextStyle(fontSize: 12)),
            onPressed: () {
              _controller.text = q;
              _sendMessage();
            },
          );
        }).toList(),
      ),
    );
  }

  /// Хабарлама жіберу аймағы
  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Сұрағыңызды жазыңыз...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _isLoading ? null : _sendMessage,
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
