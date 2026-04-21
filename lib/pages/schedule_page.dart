import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/schedule_hive_model.dart';
import '../providers/app_providers.dart';
import '../app/theme.dart';
import 'free_time_page.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
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
    int today = DateTime.now().weekday; // 1=Mon..6=Sat
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
            title: const Text(
              'Сабақ кестесі',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.timer_outlined, color: Colors.white),
                tooltip: 'Бос уақыт',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FreeTimePage(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Жаңарту',
                onPressed: () => ref.invalidate(scheduleProvider),
              ),
            ],
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
          loading: () => const Center(child: CircularProgressIndicator()),
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
                return _DayScheduleView(
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
// One day view
// ─────────────────────────────────────────────────────────────────
class _DayScheduleView extends StatelessWidget {
  final String dayName;
  final List<ScheduleHiveModel> items;
  final bool isDark;

  const _DayScheduleView({
    required this.dayName,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              '$dayName — бос күн!',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              'Бүгін сабақ жоқ 🎉',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    // Build rows: class cards + gap indicators between them
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      rows.add(_ClassCard(item: items[i], index: i, isDark: isDark));

      // Show gap between classes
      if (i < items.length - 1) {
        final gapMin = _gapMinutes(items[i].endTime, items[i + 1].startTime);
        if (gapMin >= 15) {
          rows.add(_GapTile(minutes: gapMin));
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      children: rows,
    );
  }

  int _gapMinutes(String endTime, String startTime) {
    int toMins(String t) {
      final p = t.split(':');
      return (int.tryParse(p[0]) ?? 0) * 60 +
          (int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
    }
    return (toMins(startTime) - toMins(endTime)).clamp(0, 999);
  }
}

// ─────────────────────────────────────────────────────────────────
// Class card
// ─────────────────────────────────────────────────────────────────
class _ClassCard extends StatelessWidget {
  final ScheduleHiveModel item;
  final int index;
  final bool isDark;

  const _ClassCard(
      {required this.item, required this.index, required this.isDark});

  static const _colors = [
    Color(0xFF1A237E),
    Color(0xFF00695C),
    Color(0xFF4A148C),
    Color(0xFFBF360C),
    Color(0xFF1565C0),
    Color(0xFF33691E),
  ];

  @override
  Widget build(BuildContext context) {
    final accentColor = _colors[index % _colors.length];
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Time column
            Container(
              width: 68,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.startTime,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: accentColor),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 1,
                    height: 14,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.endTime,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              width: 1,
              color: Colors.grey.shade200,
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.person_outline,
                        text: item.teacher,
                        color: cs.onSurfaceVariant),
                    const SizedBox(height: 3),
                    _InfoRow(
                        icon: Icons.room_outlined,
                        text: item.room,
                        color: cs.onSurfaceVariant),
                    if (item.groups.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _InfoRow(
                          icon: Icons.group_outlined,
                          text: item.groups.join(', '),
                          color: cs.onSurfaceVariant),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Gap indicator between classes
// ─────────────────────────────────────────────────────────────────
class _GapTile extends StatelessWidget {
  final int minutes;
  const _GapTile({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final label = h > 0
        ? (m > 0 ? '${h}с ${m}мин бос уақыт' : '${h} сағат бос уақыт')
        : '${m} мин бос уақыт';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 30),
          const Icon(Icons.more_vert, size: 16, color: Colors.green),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
