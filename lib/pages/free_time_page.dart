import 'package:flutter/material.dart';
import '../models/hive/schedule_hive_model.dart';

/// Бос уақыт ұсыныстары беті
/// Сабақ кестесімен динамикалық байланысқан
class FreeTimePage extends StatelessWidget {
  final List<ScheduleHiveModel> scheduleItems;

  const FreeTimePage({super.key, required this.scheduleItems});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int today = DateTime.now().weekday;
    final todayClasses = scheduleItems.where((i) => i.dayOfWeek == today).toList();
    final freeMinutes = _calcFreeMinutes(todayClasses);
    final String todayName = _dayName(today);

    // Бос уақытқа байланысты ұсыныстар
    final suggestions = _getSuggestions(freeMinutes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бос уақыт ұсыныстары'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Бүгінгі жағдай карточкасы
            _buildStatusCard(
              context,
              colorScheme,
              todayName,
              todayClasses.length,
              freeMinutes,
            ),
            const SizedBox(height: 20),

            // Бос уақыт деңгейі
            _buildFreeTimeLevel(colorScheme, freeMinutes),
            const SizedBox(height: 20),

            // Ұсыныстар тізімі
            Text(
              'Ұсыныстар:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
                ...suggestions.map((s) => _buildSuggestionCard(s, colorScheme)),

            const SizedBox(height: 16),

            // Бүгінгі сабақтар тізімі
            if (todayClasses.isNotEmpty) ...[
              Text(
                'Бүгінгі сабақтар ($todayName):',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...todayClasses.map((c) => _buildMiniScheduleItem(c, colorScheme)),
            ],
          ],
        ),
      ),
    );
  }

  /// Бүгінгі жағдай карточкасы
  Widget _buildStatusCard(
    BuildContext context,
    ColorScheme colorScheme,
    String dayName,
    int classCount,
    int freeMinutes,
  ) {
    final hours = freeMinutes ~/ 60;
    final mins = freeMinutes % 60;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              classCount == 0 ? Icons.celebration : Icons.access_time,
              size: 48,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classCount == 0
                        ? 'Бүгін сабақ жоқ — бос күн!'
                        : '$classCount сабақ, ~$hoursс $minsмин бос уақыт',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Бос уақыт деңгейі индикаторы
  Widget _buildFreeTimeLevel(ColorScheme colorScheme, int freeMinutes) {
    String level;
    Color levelColor;
    double progress;

    if (freeMinutes >= 360) {
      level = 'Көп бос уақыт ☀️';
      levelColor = Colors.green;
      progress = 1.0;
    } else if (freeMinutes >= 180) {
      level = 'Орташа бос уақыт 🕐';
      levelColor = Colors.orange;
      progress = 0.6;
    } else {
      level = 'Аз бос уақыт ⏰';
      levelColor = Colors.red;
      progress = 0.3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(level, style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: levelColor,
        )),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(levelColor),
          ),
        ),
      ],
    );
  }

  /// Бос уақытқа байланысты ұсыныстар тізімін қайтарады
  List<_Suggestion> _getSuggestions(int freeMinutes) {
    // Барлығына ортақ ұсыныстар
    final List<_Suggestion> all = [];

    if (freeMinutes >= 360) {
      // Көп бос уақыт (6+ сағат)
      all.addAll([
        _Suggestion(
          Icons.menu_book,
          'Кітапханаға бару',
          'Университет кітапханасында оқу материалдарын қарап шығыңыз.',
        ),
        _Suggestion(
          Icons.fitness_center,
          'Спорт залына бару',
          'Дене шынықтырумен айналысып, денсаулығыңызды нығайтыңыз.',
        ),
        _Suggestion(
          Icons.people,
          'Студенттік іс-шараларға қатысу',
          'Университет клубтары мен ұйымдарына барып көріңіз.',
        ),
        _Suggestion(
          Icons.code,
          'Жеке жобамен айналысу',
          'Курстық жұмысыңызды немесе жеке проектіңізді дамытыңыз.',
        ),
        _Suggestion(
          Icons.movie,
          'Мәдени іс-шараларға бару',
          'Көрме, кино немесе театрға уақыт бөліңіз.',
        ),
        _Suggestion(
          Icons.volunteer_activism,
          'Волонтерлік жұмыс',
          'Қоғамдық жұмыстарға қатысып, портфолиоңызды толтырыңыз.',
        ),
      ]);
    } else if (freeMinutes >= 180) {
      // Орташа бос уақыт (3-6 сағат)
      all.addAll([
        _Suggestion(
          Icons.book,
          'Келесі сабаққа дайындалу',
          'Ертеңгі сабақтардың материалдарын қарап шығыңыз.',
        ),
        _Suggestion(
          Icons.coffee,
          'Достармен кездесу',
          'Кампус кафесінде достарыңызбен уақыт өткізіңіз.',
        ),
        _Suggestion(
          Icons.headphones,
          'Подкаст тыңдау',
          'Білім беру подкасттарын тыңдап, жаңа нәрселер үйреніңіз.',
        ),
        _Suggestion(
          Icons.nature_people,
          'Серуенге шығу',
          'Кампус аумағында жаяу серуенге шығып, дем алыңыз.',
        ),
      ]);
    } else {
      // Аз бос уақыт (0-3 сағат)
      all.addAll([
        _Suggestion(
          Icons.self_improvement,
          'Қысқа дем алу',
          '15-20 минутқа дем алып, күш жинаңыз.',
        ),
        _Suggestion(
          Icons.restaurant,
          'Тамақтану',
          'Асхана немесе кафеде тамақтанып алыңыз.',
        ),
        _Suggestion(
          Icons.note_alt,
          'Конспектілерді тексеру',
          'Бүгінгі сабақтардың жазбаларын қысқаша қарап шығыңыз.',
        ),
      ]);
    }

    return all;
  }

  /// Ұсыныс карточкасы
  Widget _buildSuggestionCard(_Suggestion suggestion, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            suggestion.icon,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          suggestion.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          suggestion.description,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
  String _dayName(int d) {
    const n = ['', 'Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі', 'Жұма', 'Сенбі', 'Жексенбі'];
    return d < n.length ? n[d] : '';
  }

  int _calcFreeMinutes(List<ScheduleHiveModel> items) {
    if (items.isEmpty) return 480; // 8сағат = бос күн
    // Бірінші сабақтан соңғысына дейін тотал сабақ ұзақтығы
    int busyMinutes = items.fold(0, (sum, i) {
      final start = _parseTime(i.startTime);
      final end = _parseTime(i.endTime);
      return sum + (end - start).clamp(0, 600);
    });
    return (480 - busyMinutes).clamp(0, 480);
  }

  int _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
  /// Мини сабақ элементі
  Widget _buildMiniScheduleItem(ScheduleHiveModel item, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(
              '${item.startTime} - ${item.endTime}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.subject, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ұсыныс моделі (осы бетке ғана арналған)
class _Suggestion {
  final IconData icon;
  final String title;
  final String description;

  const _Suggestion(this.icon, this.title, this.description);
}
