import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hive/schedule_hive_model.dart';
import '../../core/firestore_sync_service.dart';
import '../../providers/app_providers.dart';

/// Admin: Сабақ кестесін басқару
class AdminSchedulePage extends ConsumerWidget {
  const AdminSchedulePage({super.key});

  static const List<String> _dayNames = [
    '', 'Дүйсенбі', 'Сейсенбі', 'Сәрсенбі',
    'Бейсенбі', 'Жұма', 'Сенбі',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (items) {
          final sorted = [...items]
            ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
          if (sorted.isEmpty) {
            return const Center(child: Text('Кесте бос'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            itemBuilder: (ctx, i) => _ScheduleTile(
              item: sorted[i],
              dayName: _dayNames[sorted[i].dayOfWeek],
              onChanged: () => ref.invalidate(scheduleProvider),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Сабақ қосу'),
      ),
    );
  }

  void _showForm(BuildContext ctx, WidgetRef ref, ScheduleHiveModel? item) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScheduleFormSheet(
        existing: item,
        onSaved: () => ref.invalidate(scheduleProvider),
      ),
    );
  }
}

class _ScheduleTile extends ConsumerWidget {
  final ScheduleHiveModel item;
  final String dayName;
  final VoidCallback onChanged;
  const _ScheduleTile(
      {required this.item, required this.dayName, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.subject,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '$dayName • ${item.startTime}-${item.endTime} • ${item.room}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            await FirestoreSyncService().deleteScheduleItem(item.id);
            onChanged();
          },
        ),
      ),
    );
  }
}

class _ScheduleFormSheet extends StatefulWidget {
  final ScheduleHiveModel? existing;
  final VoidCallback onSaved;
  const _ScheduleFormSheet({this.existing, required this.onSaved});

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subject =
      TextEditingController(text: widget.existing?.subject ?? '');
  late final TextEditingController _teacher =
      TextEditingController(text: widget.existing?.teacher ?? '');
  late final TextEditingController _room =
      TextEditingController(text: widget.existing?.room ?? '');
  late final TextEditingController _start =
      TextEditingController(text: widget.existing?.startTime ?? '08:30');
  late final TextEditingController _end =
      TextEditingController(text: widget.existing?.endTime ?? '09:50');
  late final TextEditingController _groups =
      TextEditingController(text: widget.existing?.groups.join(', ') ?? '');
  int _day = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _day = widget.existing?.dayOfWeek ?? 1;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final groupList = _groups.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final item = ScheduleHiveModel(
      id: widget.existing?.id ?? '',
      subject: _subject.text.trim(),
      teacher: _teacher.text.trim(),
      room: _room.text.trim(),
      startTime: _start.text.trim(),
      endTime: _end.text.trim(),
      dayOfWeek: _day,
      groups: groupList,
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
    const days = ['Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі', 'Жұма', 'Сенбі'];
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Сабақ қосу/өңдеу',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _day,
                decoration: const InputDecoration(labelText: 'Апта күні'),
                items: List.generate(
                    6, (i) => DropdownMenuItem(value: i + 1, child: Text(days[i]))),
                onChanged: (v) => setState(() => _day = v!),
              ),
              const SizedBox(height: 12),
              _f(_subject, 'Пән атауы'),
              _f(_teacher, 'Оқытушы'),
              _f(_room, 'Аудитория'),
              Row(children: [
                Expanded(child: _f(_start, 'Басталу (08:30)')),
                const SizedBox(width: 12),
                Expanded(child: _f(_end, 'Аяқталу (09:50)')),
              ]),
              _f(_groups, 'Топтар (ИН-21-1, ИН-21-2)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Сақтау'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(labelText: label),
          validator: (v) => v == null || v.isEmpty ? 'Міндетті' : null,
        ),
      );
}
