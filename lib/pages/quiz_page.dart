import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

/// Тест/Ойын беті
class QuizPage extends StatelessWidget {
  QuizPage({super.key});

  final QuizService _quizService = QuizService();

  @override
  Widget build(BuildContext context) {
    final categories = _quizService.getCategories();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест & Ойын'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(context, category, colorScheme, index);
        },
      ),
    );
  }

  /// Санат карточкасы
  Widget _buildCategoryCard(
    BuildContext context,
    QuizCategory category,
    ColorScheme colorScheme,
    int index,
  ) {
    // Әр санатқа әртүрлі иконка
    final icons = [Icons.history_edu, Icons.school, Icons.lightbulb];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _QuizPlayPage(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icons[index % icons.length],
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.questions.length} сұрақ',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Тест ойнау беті
class _QuizPlayPage extends StatefulWidget {
  final QuizCategory category;

  const _QuizPlayPage({required this.category});

  @override
  State<_QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<_QuizPlayPage> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answered = false;

  QuizQuestion get _currentQuestion =>
      widget.category.questions[_currentIndex];

  bool get _isLastQuestion =>
      _currentIndex == widget.category.questions.length - 1;

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _currentQuestion.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _showResult();
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    }
  }

  void _showResult() {
    final total = widget.category.questions.length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Нәтиже'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _score >= total * 0.7
                    ? Icons.emoji_events
                    : Icons.sentiment_neutral,
                size: 64,
                color: _score >= total * 0.7 ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '$_score / $total',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _score >= total * 0.7
                    ? 'Керемет нәтиже! 🎉'
                    : 'Тағы қайталап көріңіз!',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog жабу
                Navigator.pop(context); // Тест бетінен шығу
              },
              child: const Text('Артқа'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                  _score = 0;
                  _selectedOption = null;
                  _answered = false;
                });
              },
              child: const Text('Қайтадан'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = widget.category.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Прогресс
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Сұрақ ${_currentIndex + 1} / $total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'Ұпай: $_score',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Сұрақ
            Text(
              _currentQuestion.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Жауап нұсқалары
            Expanded(
              child: ListView.builder(
                itemCount: _currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return _buildOptionTile(index, colorScheme);
                },
              ),
            ),

            // Келесі сұрақ батырмасы
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextQuestion,
                  child: Text(_isLastQuestion ? 'Нәтижені көру' : 'Келесі'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Жауап нұсқасы виджеті
  Widget _buildOptionTile(int index, ColorScheme colorScheme) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == _currentQuestion.correctIndex;

    Color? tileColor;
    if (_answered) {
      if (isCorrect) {
        tileColor = Colors.green.withValues(alpha: 0.15);
      } else if (isSelected && !isCorrect) {
        tileColor = Colors.red.withValues(alpha: 0.15);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: tileColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectOption(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _currentQuestion.options[index],
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                if (_answered && isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (_answered && isSelected && !isCorrect)
                  const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
