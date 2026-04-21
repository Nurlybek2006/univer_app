import 'package:hive/hive.dart';

part 'quiz_hive_model.g.dart';

/// Тест сұрағы — Hive локалдық моделі
@HiveType(typeId: 3)
class QuizQuestionHiveModel extends HiveObject {
  @HiveField(0)
  late String question;

  @HiveField(1)
  late List<String> options;

  @HiveField(2)
  late int correctIndex;

  QuizQuestionHiveModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// Тест санаты — Hive локалдық моделі
@HiveType(typeId: 4)
class QuizCategoryHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late List<QuizQuestionHiveModel> questions;

  QuizCategoryHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'questions': questions.map((q) => {
              'question': q.question,
              'options': q.options,
              'correctIndex': q.correctIndex,
            }).toList(),
      };

  factory QuizCategoryHiveModel.fromFirestore(
      String docId, Map<String, dynamic> d) {
    final rawQuestions = d['questions'] as List<dynamic>? ?? [];
    return QuizCategoryHiveModel(
      id: docId,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      questions: rawQuestions.map((q) {
        final qMap = q as Map<String, dynamic>;
        return QuizQuestionHiveModel(
          question: qMap['question'] ?? '',
          options: List<String>.from(qMap['options'] ?? []),
          correctIndex: (qMap['correctIndex'] as num?)?.toInt() ?? 0,
        );
      }).toList(),
    );
  }
}
