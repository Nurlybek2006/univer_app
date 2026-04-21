import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/hive/news_hive_model.dart';
import '../../core/firestore_sync_service.dart';
import '../../providers/app_providers.dart';

/// Admin: Жаңалықтарды басқару
class AdminNewsPage extends ConsumerWidget {
  const AdminNewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return Scaffold(
      body: newsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (newsList) {
          if (newsList.isEmpty) {
            return const Center(child: Text('Жаңалық жоқ'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: newsList.length,
            itemBuilder: (ctx, i) => _NewsTile(
              item: newsList[i],
              onChanged: () => ref.invalidate(newsProvider),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Жаңалық қосу'),
      ),
    );
  }

  void _showForm(BuildContext ctx, WidgetRef ref, NewsHiveModel? item) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewsFormSheet(
        existing: item,
        onSaved: () => ref.invalidate(newsProvider),
      ),
    );
  }
}

class _NewsTile extends ConsumerWidget {
  final NewsHiveModel item;
  final VoidCallback onChanged;
  const _NewsTile({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(DateFormat('dd.MM.yyyy').format(item.date)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            await FirestoreSyncService().deleteNews(item.id);
            onChanged();
          },
        ),
      ),
    );
  }
}

class _NewsFormSheet extends StatefulWidget {
  final NewsHiveModel? existing;
  final VoidCallback onSaved;
  const _NewsFormSheet({this.existing, required this.onSaved});

  @override
  State<_NewsFormSheet> createState() => _NewsFormSheetState();
}

class _NewsFormSheetState extends State<_NewsFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _image =
      TextEditingController(text: widget.existing?.imageUrl ?? '');
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final item = NewsHiveModel(
      id: widget.existing?.id ?? '',
      title: _title.text.trim(),
      description: _desc.text.trim(),
      imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
      date: DateTime.now(),
    );
    final sync = FirestoreSyncService();
    if (widget.existing == null) {
      await sync.addNews(item);
    } else {
      await sync.updateNews(item);
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
              const Text('Жаңалық қосу/өңдеу',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Тақырып'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Міндетті' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Мазмұн'),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Міндетті' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _image,
                decoration:
                    const InputDecoration(labelText: 'Сурет URL (міндетті емес)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Жариялау'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
