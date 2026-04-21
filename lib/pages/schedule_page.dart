import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/schedule_hive_model.dart';
import '../providers/app_providers.dart';
import 'free_time_page.dart';

/// Сабақ кестесі беті
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Апта күндері (Дүйсенбі - Сенбі)
  final List<String> _dayNames = [
    'Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сб',
  ];

  @override
  void initState() {
    super.initState();
    // Бүгінгі күнге автоматты ауысу
    int initialIndex = DateTime.now().weekday - 1;
    if (initialIndex > 5) initialIndex = 0; // Жексенбі → Дүйсенбіге
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheduleAsync = ref.watch(scheduleProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сабақ кестесі'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(scheduleProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: List.generate(6, (i) {
              final isToday = DateTime.now().weekday == i + 1;
              return Tab(
                child: Text(
                  _dayNames[i],
                  style: TextStyle(
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Кесте жүктелмеді: $e')),
        data: (allItems) {
          // Студенттің тобына қарай сүзу
          final group = user?.group ?? '';
          final filtered = allItems.where((item) {
            if (item.groups.isEmpty) return true;
            return item.groups.contains(group);
          }).toList();
          return TabBarView(
            controller: _tabController,
            children: List.generate(6, (i) {
              return _buildDaySchedule(i + 1, filtered, colorScheme);
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final all = ref.read(scheduleProvider).value ?? [];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FreeTimePage(scheduleItems: all),
            ),
          );
        },
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Бос уақыт'),
      ),
    );
  }

  /// Белгілі бір күндегі сабақтар тізімі
  Widget _buildDaySchedule(int dayOfWeek, List<ScheduleHiveModel> allItems, ColorScheme colorScheme) {
    final items = allItems.where((i) => i.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final dayFullName = _dayFullName(dayOfWeek);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              '$dayFullName — сабақ жоқ 🎉',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Бос уақытыңызды пайдалы өткізіңіз!',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length + 1, // +1 күн тақырыбы
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              dayFullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }
        return _buildScheduleCard(items[index - 1], colorScheme);
      },
    );
  }

  String _dayFullName(int d) {
    const names = ['', 'Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі', 'Жұма', 'Сенбі'];
    return d < names.length ? names[d] : '';
  }

  /// Сабақ карточкасы
  Widget _buildScheduleCard(ScheduleHiveModel item, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Уақыт бағанасы
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    item.startTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    item.endTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Сабақ ақпараты
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.teacher,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.room_outlined,
                          size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        item.room,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
