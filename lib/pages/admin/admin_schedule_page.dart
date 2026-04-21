import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hive/schedule_hive_model.dart';
import '../../core/firestore_sync_service.dart';
import '../../providers/app_providers.dart';
import '../../app/theme.dart';

/// Admin: Сабақ кестесін басқару
class AdminSchedulePage extends ConsumerStatefulWidget {
  const AdminSchedulePage({super.key});

  @override
  ConsumerState<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends ConsumerState<AdminSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _dayNames = [
    '',
    'Дүйсенбі',
    'Сейсенбі',
    'Сәрсенбі',
    'Бейсенбі',
    'Жұма',
    'Сенбі',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => ref.invalidate(scheduleProvider);

  void _openForm([ScheduleHiveModel? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleFormSheet(
        existing: item,
        defaultDay: _tabController.index + 1,
        onSaved: _refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // TabBar
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.primary,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Дс'),
                Tab(text: 'Сс'),
                Tab(text: 'Ср'),
                Tab(text: 'Бс'),
                Tab(text: 'Жм'),
                Tab(text: 'Сб'),
              ],
            ),
          ),
          Expanded(
            child: scheduleAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Қате: $e')),
              data: (items) => TabBarView(
                controller: _tabController,
                children: List.generate(6, (i) {
                  final day = i + 1;
                  final dayItems = items
                      .where((s) => s.dayOfWeek == day)
                      .toList()
                    ..sort((a, b) => a.startTime.compareTo(b.startTime));
                  return _DayTab(
                    dayName: _dayNames[day],
                    items: dayItems,
                    onAdd: () => _openForm(),
                    onEdit: _openForm,
                    onDelete: (id) async {
                      await FirestoreSyncService().deleteScheduleItem(id);
                      _refresh();
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Сабақ қосу'),
      ),
    );
  }
}

// ── Day tab content ──
class _DayTab extends StatelessWidget {
  final String dayName;
  final List<ScheduleHiveModel> items;
  final VoidCallback onAdd;
  final void Function(ScheduleHiveModel) onEdit;
  final void Function(String) onDelete;

  const _DayTab({
    required this.dayName,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('$dayName — сабақ жоқ',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Сабақ қосу'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _AdminScheduleCard(
        item: items[i],
        onEdit: () => onEdit(items[i]),
        onDelete: () => onDelete(items[i].id),
      ),
    );
  }
}

// ── Admin schedule card ──
class _AdminScheduleCard extends StatelessWidget {
  final ScheduleHiveModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AdminScheduleCard(
      {required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.startTime,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer)),
              Text(item.endTime,
                  style: TextStyle(
                      fontSize: 11,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
            ],
          ),
        ),
        title: Text(item.subject,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${item.teacher} • ${item.room}'
          '${item.groups.isNotEmpty ? " • ${item.groups.join(", ")}" : ""}',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Form Sheet
// ──────────────────────────────────────────────────────────────────
class _ScheduleFormSheet extends StatefulWidget {
  final ScheduleHiveModel? existing;
  final int defaultDay;
  final VoidCallback onSaved;
  const _ScheduleFormSheet(
      {this.existing, required this.defaultDay, required this.onSaved});

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late int _day;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _subject;
  late final TextEditingController _teacher;
  late final TextEditingController _room;
  late final TextEditingController _groups;
  bool _saving = false;

  static const _days = [
    'Дүйсенбі',
    'Сейсенбі',
    'Сәрсенбі',
    'Бейсенбі',
    'Жұма',
    'Сенбі',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _day = e?.dayOfWeek ?? widget.defaultDay;
    _startTime = _parse(e?.startTime ?? '08:30');
    _endTime = _parse(e?.endTime ?? '10:00');
    _subject = TextEditingController(text: e?.subject ?? '');
    _teacher = TextEditingController(text: e?.teacher ?? '');
    _room = TextEditingController(text: e?.room ?? '');
    _groups = TextEditingController(text: e?.groups.join(', ') ?? '');
  }

  TimeOfDay _parse(String t) {
    final p = t.split(':');
    return TimeOfDay(
        hour: int.tryParse(p[0]) ?? 8,
        minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final groups = _groups.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final item = ScheduleHiveModel(
      id: widget.existing?.id ?? '',
      subject: _subject.text.trim(),
      teacher: _teacher.text.trim(),
      room: _room.text.trim(),
      startTime: _fmt(_startTime),
      endTime: _fmt(_endTime),
      dayOfWeek: _day,
      groups: groups,
    );

    final sync = FirestoreSyncService();
    if (widget.existing == null) {
      await sync.addScheduleItem(item);
    } else {
      await sync.updateScheduleItem(item);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.existing == null ? 'Сабақ қосу' : 'Сабақты өңдеу',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Day selector
              DropdownButtonFormField<int>(
                initialValue: _day,
                decoration: const InputDecoration(
                  labelText: 'Апта күні',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                items: List.generate(
                  6,
                  (i) => DropdownMenuItem(
                      value: i + 1, child: Text(_days[i])),
                ),
                onChanged: (v) => setState(() => _day = v!),
              ),
              const SizedBox(height: 12),

              // Time row
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Басталу',
                      time: _startTime,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'Аяқталу',
                      time: _endTime,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _field(_subject, 'Пән атауы', Icons.book_outlined),
              _field(_teacher, 'Оқытушы', Icons.person_outline),
              _field(_room, 'Аудитория', Icons.room_outlined),
              // Groups — міндетті емес
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _groups,
                  decoration: const InputDecoration(
                    labelText: 'Топтар (мін. емес)',
                    hintText: 'ИН-21-1, ИН-21-2',
                    prefixIcon: Icon(Icons.group_outlined),
                    helperText: 'Бос қалдырсаңыз — барлық топқа',
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(widget.existing == null ? 'Қосу' : 'Сақтау',
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(
              labelText: label, prefixIcon: Icon(icon)),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Міндетті өріс' : null,
        ),
      );
}

// ── Time picker tile ──
class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeTile(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
                Text(fmt,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
