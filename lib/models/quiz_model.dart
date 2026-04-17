/// Тест сұрағының моделі
class QuizQuestion {
  final String question;          // Сұрақ
  final List<String> options;     // Жауап нұсқалары
  final int correctIndex;         // Дұрыс жауап индексі

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// Тест санатының моделі
class QuizCategory {
  final String title;               // Санат атауы
  final String description;         // Сипаттама
  final List<QuizQuestion> questions;

  const QuizCategory({
    required this.title,
    required this.description,
    required this.questions,
  });
}
