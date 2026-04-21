import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/schedule_hive_model.dart';
import '../providers/app_providers.dart';


/// Бос уақыт ұсыныстары беті — сабақ кестесімен тікелей байланыста
class FreeTimePage extends ConsumerStatefulWidget {
  const FreeTimePage({super.key});

  @override
  ConsumerState<FreeTimePage> createState() => _FreeTimePageState();
}

class _FreeTimePageState extends ConsumerState<FreeTimePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _dayNames = [
    '',
    'Дүйсенбі',
    'Сейсенбі',
    'Сәрсенбі',
    'Бейсенбі',
    'Жұма',
    'Сенбі',
  ];
  static const _shortDays = ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сб'];

  @override
  void initState() {
    super.initState();
    int today = DateTime.now().weekday;
    if (today > 6) today = 1;
    _tabController =
        TabController(length: 6, vsync: this, initialIndex: today - 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Бос уақыт ұсыныстары',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF009688), Color(0xFF4DB6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: _shortDays.map((d) => Tab(text: d)).toList(),
            ),
          ),
        ],
        body: scheduleAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Қате: $e')),
          data: (allItems) {
            final group = userAsync?.group ?? '';
            final filtered = allItems.where((i) {
              if (i.groups.isEmpty) return true;
              return i.groups.any((g) =>
                  g.trim().toLowerCase() == group.trim().toLowerCase());
            }).toList();

            return TabBarView(
              controller: _tabController,
              children: List.generate(6, (i) {
                final day = i + 1;
                final dayItems = filtered
                    .where((s) => s.dayOfWeek == day)
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));
                return _DayFreeTimePage(
                  dayName: _dayNames[day],
                  items: dayItems,
                  isDark: isDark,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Per-day free time analysis
// ─────────────────────────────────────────────────────────────────
class _DayFreeTimePage extends StatelessWidget {
  final String dayName;
  final List<ScheduleHiveModel> items;
  final bool isDark;

  const _DayFreeTimePage({
    required this.dayName,
    required this.items,
    required this.isDark,
  });

  // Parse "HH:MM" → minutes
  int _toMins(String t) {
    final p = t.split(':');
    return (int.tryParse(p[0]) ?? 0) * 60 +
        (int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  // List of free gaps {start, end} in minutes (before/between/after classes)
  List<_Gap> _calcGaps() {
    if (items.isEmpty) {
      // Full day free
      return [_Gap('08:00', '18:00', 600)];
    }

    final gaps = <_Gap>[];
    const dayStart = 8 * 60; // 08:00
    const dayEnd = 20 * 60;  // 20:00

    final firstStart = _toMins(items.first.startTime);
    if (firstStart - dayStart >= 15) {
      gaps.add(_Gap('08:00', items.first.startTime, firstStart - dayStart));
    }

    for (int i = 0; i < items.length - 1; i++) {
      final gapStart = _toMins(items[i].endTime);
      final gapEnd = _toMins(items[i + 1].startTime);
      final gapMin = gapEnd - gapStart;
      if (gapMin >= 15) {
        gaps.add(_Gap(items[i].endTime, items[i + 1].startTime, gapMin));
      }
    }

    final lastEnd = _toMins(items.last.endTime);
    if (dayEnd - lastEnd >= 15) {
      gaps.add(_Gap(items.last.endTime, '20:00', dayEnd - lastEnd));
    }

    return gaps;
  }

  int _totalFreeMinutes(List<_Gap> gaps) =>
      gaps.fold(0, (s, g) => s + g.minutes);

  @override
  Widget build(BuildContext context) {
    final gaps = _calcGaps();
    final totalFree = _totalFreeMinutes(gaps);
    final cs = Theme.of(context).colorScheme;

    final totalClasses = items.fold(0, (s, i) {
      return s + (_toMins(i.endTime) - _toMins(i.startTime)).clamp(0, 600);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _StatusCard(
            dayName: dayName,
            classCount: items.length,
            totalFreeMinutes: totalFree,
            totalClassMinutes: totalClasses,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Free time slots
          if (gaps.isNotEmpty) ...[
            Text(
              'Бос уақыт аралықтары:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...gaps.map((g) => _GapCard(gap: g, isDark: isDark)),
            const SizedBox(height: 16),
          ],

          // Today's classes mini
          if (items.isNotEmpty) ...[
            Text(
              'Бүгінгі сабақтар:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((c) => _MiniClassTile(item: c, cs: cs)),
            const SizedBox(height: 16),
          ],

          // Suggestions
          Text(
            'Ұсыныстар:',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._getSuggestions(totalFree)
              .map((s) => _SuggestionCard(suggestion: s, cs: cs)),
        ],
      ),
    );
  }

  List<_Suggestion> _getSuggestions(int freeMinutes) {
    if (freeMinutes >= 360) {
      return [
        _Suggestion(Icons.menu_book, 'Кітапханаға бару',
            'Университет кітапханасында оқу материалдарын қарап шығыңыз.'),
        _Suggestion(Icons.fitness_center, 'Спорт залына бару',
            'Дене шынықтырумен айналысып, денсаулығыңызды нығайтыңыз.'),
        _Suggestion(Icons.people, 'Студенттік іс-шараларға қатысу',
            'Университет клубтары мен ұйымдарына барып көріңіз.'),
        _Suggestion(Icons.code, 'Жеке жобамен айналысу',
            'Курстық жұмысыңызды немесе жеке проектіңізді дамытыңыз.'),
        _Suggestion(Icons.volunteer_activism, 'Волонтерлік жұмыс',
            'Қоғамдық жұмыстарға қатысып, портфолиоңызды толтырыңыз.'),
      ];
    } else if (freeMinutes >= 180) {
      return [
        _Suggestion(Icons.book, 'Келесі сабаққа дайындалу',
            'Ертеңгі сабақтардың материалдарын қарап шығыңыз.'),
        _Suggestion(Icons.coffee, 'Достармен кездесу',
            'Кампус кафесінде достарыңызбен уақыт өткізіңіз.'),
        _Suggestion(Icons.headphones, 'Подкаст тыңдау',
            'Білім беру подкасттарын тыңдап, жаңа нәрселер үйреніңіз.'),
        _Suggestion(Icons.nature_people, 'Серуенге шығу',
            'Кампус аумағында жаяу серуенге шығып, дем алыңыз.'),
      ];
    } else if (freeMinutes >= 60) {
      return [
        _Suggestion(Icons.note_alt, 'Конспектілерді тексеру',
            'Бүгінгі сабақтардың жазбаларын қысқаша қарап шығыңыз.'),
        _Suggestion(Icons.restaurant, 'Тамақтану',
            'Асхана немесе кафеде тамақтанып алыңыз.'),
        _Suggestion(Icons.self_improvement, 'Қысқа дем алу',
            '15-20 минутқа дем алып, күш жинаңыз.'),
      ];
    } else {
      return [
        _Suggestion(Icons.self_improvement, 'Қысқа дем алу',
            'Сабақтар арасында тынығу маңызды — 5-10 мин дем алыңыз.'),
        _Suggestion(Icons.restaurant, 'Тамақтану',
            'Тамақ ішуді ұмытпаңыз — дұрыс тамақтану өнімділікті арттырады.'),
      ];
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final String dayName;
  final int classCount;
  final int totalFreeMinutes;
  final int totalClassMinutes;
  final bool isDark;

  const _StatusCard({
    required this.dayName,
    required this.classCount,
    required this.totalFreeMinutes,
    required this.totalClassMinutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final freeH = totalFreeMinutes ~/ 60;
    final freeM = totalFreeMinutes % 60;
    final classH = totalClassMinutes ~/ 60;
    final classM = totalClassMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF009688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                classCount == 0 ? Icons.celebration : Icons.calendar_today,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                dayName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  classCount == 0 ? 'Бос күн' : '$classCount сабақ',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                icon: Icons.free_breakfast_outlined,
                label: 'Бос уақыт',
                value: '${freeH}с ${freeM}м',
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 24),
              _StatItem(
                icon: Icons.school_outlined,
                label: 'Сабақта',
                value: classCount == 0 ? '—' : '${classH}с $classM м',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7))),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _GapCard extends StatelessWidget {
  final _Gap gap;
  final bool isDark;
  const _GapCard({required this.gap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = gap.minutes ~/ 60;
    final m = gap.minutes % 60;
    final label = h > 0
        ? (m > 0 ? '$h сағат $m мин' : '$h сағат')
        : '$m минут';
    final isLong = gap.minutes >= 120;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isLong
            ? Colors.green.withValues(alpha: isDark ? 0.15 : 0.08)
            : Colors.orange.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLong
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLong ? Icons.check_circle_outline : Icons.timer_outlined,
            color: isLong ? Colors.green : Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${gap.startLabel} — ${gap.endLabel}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '$label бос уақыт',
                style: TextStyle(
                    fontSize: 12,
                    color: isLong ? Colors.green : Colors.orange),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLong
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isLong ? '✓ Демалу' : '⏱ Аз',
              style: TextStyle(
                  fontSize: 11,
                  color: isLong ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniClassTile extends StatelessWidget {
  final ScheduleHiveModel item;
  final ColorScheme cs;
  const _MiniClassTile({required this.item, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '${item.startTime}–${item.endTime}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(item.subject,
                  style: const TextStyle(fontSize: 13))),
          Text(item.room,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final _Suggestion suggestion;
  final ColorScheme cs;
  const _SuggestionCard({required this.suggestion, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(suggestion.icon, color: cs.onSecondaryContainer),
        ),
        title: Text(suggestion.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          suggestion.description,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────
class _Gap {
  final String startLabel;
  final String endLabel;
  final int minutes;
  const _Gap(this.startLabel, this.endLabel, this.minutes);
}

class _Suggestion {
  final IconData icon;
  final String title;
  final String description;
  const _Suggestion(this.icon, this.title, this.description);
}
