import 'package:hive/hive.dart';

part 'news_hive_model.g.dart';

/// Жаңалық элементі — Hive локалдық моделі
@HiveType(typeId: 2)
class NewsHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String? imageUrl;

  @HiveField(4)
  late DateTime date;

  NewsHiveModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
  });

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'date': date.toIso8601String(),
      };

  factory NewsHiveModel.fromFirestore(String docId, Map<String, dynamic> d) =>
      NewsHiveModel(
        id: docId,
        title: d['title'] ?? '',
        description: d['description'] ?? '',
        imageUrl: d['imageUrl'],
        date: d['date'] != null
            ? DateTime.tryParse(d['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
