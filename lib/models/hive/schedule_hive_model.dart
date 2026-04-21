import 'package:hive/hive.dart';

part 'schedule_hive_model.g.dart';

/// Сабақ кестесінің элементі — Hive локалдық моделі
@HiveType(typeId: 1)
class ScheduleHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subject;

  @HiveField(2)
  late String teacher;

  @HiveField(3)
  late String room;

  @HiveField(4)
  late String startTime;

  @HiveField(5)
  late String endTime;

  @HiveField(6)
  late int dayOfWeek;

  /// Қандай топтарға тиесілі (бос тізім = барлығына)
  @HiveField(7)
  late List<String> groups;

  ScheduleHiveModel({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.groups,
  });

  Map<String, dynamic> toFirestore() => {
        'subject': subject,
        'teacher': teacher,
        'room': room,
        'startTime': startTime,
        'endTime': endTime,
        'dayOfWeek': dayOfWeek,
        'groups': groups,
      };

  factory ScheduleHiveModel.fromFirestore(String docId, Map<String, dynamic> d) =>
      ScheduleHiveModel(
        id: docId,
        subject: d['subject'] ?? '',
        teacher: d['teacher'] ?? '',
        room: d['room'] ?? '',
        startTime: d['startTime'] ?? '',
        endTime: d['endTime'] ?? '',
        dayOfWeek: (d['dayOfWeek'] as num?)?.toInt() ?? 1,
        groups: List<String>.from(d['groups'] ?? []),
      );
}
