import 'package:hive/hive.dart';

part 'free_time_hive_model.g.dart';

/// Бос уақыт ұсынысы — Hive локалдық моделі
@HiveType(typeId: 5)
class FreeTimeHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String iconName; // Icon кілті (мысалы: 'book', 'fitness')

  /// Бос уақыт деңгейі: 'low' | 'medium' | 'high'
  @HiveField(4)
  late String level;

  FreeTimeHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.level,
  });

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'iconName': iconName,
        'level': level,
      };

  factory FreeTimeHiveModel.fromFirestore(
      String docId, Map<String, dynamic> d) =>
      FreeTimeHiveModel(
        id: docId,
        title: d['title'] ?? '',
        description: d['description'] ?? '',
        iconName: d['iconName'] ?? 'lightbulb',
        level: d['level'] ?? 'medium',
      );
}
