import '../models/schedule_model.dart';

/// Сабақ кестесін басқару сервисі
class ScheduleService {
  /// Апта бойынша үлгі кесте (Абай ҚазҰПУ форматында)
  List<ScheduleItem> getWeeklySchedule() {
    return const [
      // Дүйсенбі
      ScheduleItem(
        subject: 'Математикалық талдау',
        teacher: 'Әбдірахманова Г.К.',
        room: '305-ауд.',
        startTime: '08:30',
        endTime: '09:50',
        dayOfWeek: 1,
      ),
      ScheduleItem(
        subject: 'Информатика негіздері',
        teacher: 'Сейтқазиев Б.Н.',
        room: '412-ауд.',
        startTime: '10:00',
        endTime: '11:20',
        dayOfWeek: 1,
      ),
      ScheduleItem(
        subject: 'Қазақ тілі',
        teacher: 'Мұратова А.С.',
        room: '210-ауд.',
        startTime: '11:30',
        endTime: '12:50',
        dayOfWeek: 1,
      ),

      // Сейсенбі
      ScheduleItem(
        subject: 'Физика',
        teacher: 'Жұмабаев Қ.Т.',
        room: '501-ауд.',
        startTime: '08:30',
        endTime: '09:50',
        dayOfWeek: 2,
      ),
      ScheduleItem(
        subject: 'Педагогика',
        teacher: 'Оразбаева Ш.М.',
        room: '118-ауд.',
        startTime: '10:00',
        endTime: '11:20',
        dayOfWeek: 2,
      ),

      // Сәрсенбі
      ScheduleItem(
        subject: 'Алгебра және геометрия',
        teacher: 'Тілеуберді Е.О.',
        room: '303-ауд.',
        startTime: '08:30',
        endTime: '09:50',
        dayOfWeek: 3,
      ),
      ScheduleItem(
        subject: 'Ағылшын тілі',
        teacher: 'Смағұлова Д.Р.',
        room: '215-ауд.',
        startTime: '10:00',
        endTime: '11:20',
        dayOfWeek: 3,
      ),
      ScheduleItem(
        subject: 'Дене шынықтыру',
        teacher: 'Бекболатов Н.А.',
        room: 'Спорт залы',
        startTime: '11:30',
        endTime: '12:50',
        dayOfWeek: 3,
      ),

      // Бейсенбі
      ScheduleItem(
        subject: 'Математикалық талдау',
        teacher: 'Әбдірахманова Г.К.',
        room: '305-ауд.',
        startTime: '08:30',
        endTime: '09:50',
        dayOfWeek: 4,
      ),
      ScheduleItem(
        subject: 'Психология',
        teacher: 'Қасымова Л.Б.',
        room: '220-ауд.',
        startTime: '10:00',
        endTime: '11:20',
        dayOfWeek: 4,
      ),
      ScheduleItem(
        subject: 'Информатика негіздері',
        teacher: 'Сейтқазиев Б.Н.',
        room: '412-ауд.',
        startTime: '11:30',
        endTime: '12:50',
        dayOfWeek: 4,
      ),

      // Жұма
      ScheduleItem(
        subject: 'Қазақстан тарихы',
        teacher: 'Нұрланов М.Ж.',
        room: '102-ауд.',
        startTime: '08:30',
        endTime: '09:50',
        dayOfWeek: 5,
      ),
      ScheduleItem(
        subject: 'Философия',
        teacher: 'Ахметов С.Д.',
        room: '110-ауд.',
        startTime: '10:00',
        endTime: '11:20',
        dayOfWeek: 5,
      ),

      // Сенбі
      ScheduleItem(
        subject: 'Алгебра және геометрия',
        teacher: 'Тілеуберді Е.О.',
        room: '303-ауд.',
        startTime: '10:00',
        endTime: '11:20',
        dayOfWeek: 6,
      ),
    ];
  }

  /// Белгілі бір күнге сабақтарды қайтару
  List<ScheduleItem> getScheduleForDay(int dayOfWeek) {
    return getWeeklySchedule()
        .where((item) => item.dayOfWeek == dayOfWeek)
        .toList();
  }

  /// Бүгінгі күнге сабақ кестесін қайтару
  List<ScheduleItem> getTodaySchedule() {
    int today = DateTime.now().weekday; // 1=Monday ... 7=Sunday
    if (today == 7) return []; // Жексенбі — демалыс
    return getScheduleForDay(today);
  }

  /// Студенттің бос уақытын анықтау (минутпен)
  /// Бүгінгі сабақтарға негізделген
  int getFreeTimeMinutes() {
    final todayClasses = getTodaySchedule();
    if (todayClasses.isEmpty) return 480; // Бос күн — 8 сағат

    // Жалпы оқу уақыты (08:30 - 17:00 = 510 минут)
    const totalDayMinutes = 510;

    // Сабақтарға кеткен уақытты есептеу
    int busyMinutes = 0;
    for (final item in todayClasses) {
      final start = _parseTime(item.startTime);
      final end = _parseTime(item.endTime);
      busyMinutes += end.difference(start).inMinutes;
    }

    return totalDayMinutes - busyMinutes;
  }

  /// Уақыт жолын DateTime-ге түрлендіру
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2024, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }
}
