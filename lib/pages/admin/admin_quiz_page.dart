import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hive/quiz_hive_model.dart';
import '../../core/firestore_sync_service.dart';
import '../../providers/app_providers.dart';

/// Admin: Тест мазмұнын басқару
class AdminQuizPage extends ConsumerWidget {
  const AdminQuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizProvider);

    return Scaffold(
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (cats) {
          if (cats.isEmpty) {
            return const Center(child: Text('Тест санаты жоқ'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cats.length,
            itemBuilder: (ctx, i) => _QuizTile(
              item: cats[i],
              onChanged: () => ref.invalidate(quizProvider),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Санат қосу'),
      ),
    );
  }

  void _showForm(BuildContext ctx, WidgetRef ref, QuizCategoryHiveModel? item) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _QuizFormSheet(
        existing: item,
        onSaved: () => ref.invalidate(quizProvider),
      ),
    );
  }
}

class _QuizTile extends ConsumerWidget {
  final QuizCategoryHiveModel item;
  final VoidCallback onChanged;
  const _QuizTile({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${item.questions.length} сұрақ'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            await FirestoreSyncService().deleteQuizCategory(item.id);
            onChanged();
          },
        ),
      ),
    );
  }
}

class _QuizFormSheet extends StatefulWidget {
  final QuizCategoryHiveModel? existing;
  final VoidCallback onSaved;
  const _QuizFormSheet({this.existing, required this.onSaved});

  @override
  State<_QuizFormSheet> createState() => _QuizFormSheetState();
}

class _QuizFormSheetState extends State<_QuizFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.existing?.description ?? '');

  // Сұрақтар тізімін басқару
  final List<_QuestionEntry> _questions = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      for (final q in widget.existing!.questions) {
        _questions.add(_QuestionEntry(
          question: q.question,
          options: List.from(q.options),
          correctIndex: q.correctIndex,
        ));
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionEntry(
        question: '',
        options: ['', '', '', ''],
        correctIndex: 0,
      ));
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Кем дегенде бір сұрақ қосыңыз')));
      return;
    }
    setState(() => _saving = true);

    final cat = QuizCategoryHiveModel(
      id: widget.existing?.id ?? '',
      title: _title.text.trim(),
      description: _desc.text.trim(),
      questions: _questions
          .map((e) => QuizQuestionHiveModel(
                question: e.question,
                options: e.options,
                correctIndex: e.correctIndex,
              ))
          .toList(),
    );

    final sync = FirestoreSyncService();
    if (widget.existing == null) {
      await sync.addQuizCategory(cat);
    } else {
      await sync.updateQuizCategory(cat);
    }
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('Тест санаты',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Санат атауы'),
                validator: (v) => v == null || v.isEmpty ? 'Міндетті' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Сипаттама'),
                validator: (v) => v == null || v.isEmpty ? 'Міндетті' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(_questions.length, (i) => _QuestionWidget(
                    index: i,
                    entry: _questions[i],
                    onRemove: () => setState(() => _questions.removeAt(i)),
                    onChanged: () => setState(() {}),
                  )),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Сұрақ қосу'),
              ),
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
}

/// Жеке сұрақ жолы
class _QuestionEntry {
  String question;
  List<String> options;
  int correctIndex;
  _QuestionEntry(
      {required this.question,
      required this.options,
      required this.correctIndex});
}

class _QuestionWidget extends StatelessWidget {
  final int index;
  final _QuestionEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _QuestionWidget({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Сұрақ ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                ),
              ],
            ),
            TextFormField(
              initialValue: entry.question,
              decoration: const InputDecoration(labelText: 'Сұрақ мәтіні'),
              onChanged: (v) => entry.question = v,
            ),
            const SizedBox(height: 8),
            ...List.generate(entry.options.length, (oi) => Row(
                  children: [
                    Checkbox(
                      value: entry.correctIndex == oi,
                      onChanged: (_) {
                        entry.correctIndex = oi;
                        onChanged();
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.options[oi],
                        decoration:
                            InputDecoration(labelText: '${oi + 1}-нұсқа'),
                        onChanged: (v) => entry.options[oi] = v,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
