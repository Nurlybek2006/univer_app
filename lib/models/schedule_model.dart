/// Сабақ кестесінің моделі
class ScheduleItem {
  final String subject;    // Пән атауы
  final String teacher;    // Оқытушы
  final String room;       // Аудитория
  final String startTime;  // Басталу уақыты
  final String endTime;    // Аяқталу уақыты
  final int dayOfWeek;     // Апта күні (1=Дүйсенбі ... 6=Сенбі)

  const ScheduleItem({
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
  });

  /// Апта күнін қазақша қайтарады
  static String dayName(int day) {
    switch (day) {
      case 1: return 'Дүйсенбі';
      case 2: return 'Сейсенбі';
      case 3: return 'Сәрсенбі';
      case 4: return 'Бейсенбі';
      case 5: return 'Жұма';
      case 6: return 'Сенбі';
      default: return '';
    }
  }
}
