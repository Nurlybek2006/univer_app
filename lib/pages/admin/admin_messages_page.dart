import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firestore_sync_service.dart';
import '../../models/hive/user_hive_model.dart';
import '../../providers/app_providers.dart';

/// Admin: Студенттерге хабарлама жіберу
class AdminMessagesPage extends ConsumerStatefulWidget {
  const AdminMessagesPage({super.key});

  @override
  ConsumerState<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends ConsumerState<AdminMessagesPage> {
  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final admin = ref.watch(currentUserProvider);

    return Scaffold(
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Студент жоқ'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: students.length,
            itemBuilder: (ctx, i) => _StudentMessageTile(
              student: students[i],
              senderName: admin?.fullName ?? 'Admin',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sendToAll(context, admin?.fullName ?? 'Admin'),
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('Барлығына жіберу'),
      ),
    );
  }

  Future<void> _sendToAll(BuildContext context, String senderName) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Барлығына хабарлама'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Тақырып'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Мазмұн'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Жіберу'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (titleCtrl.text.trim().isEmpty) return;

    final students = ref.read(allStudentsProvider).value ?? [];
    final sync = FirestoreSyncService();
    for (final s in students) {
      await sync.sendMessage(
        studentId: s.uid,
        title: titleCtrl.text.trim(),
        body: bodyCtrl.text.trim(),
        senderName: senderName,
      );
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Хабарлама барлық студенттерге жіберілді ✓')),
      );
    }
  }
}

class _StudentMessageTile extends ConsumerWidget {
  final UserHiveModel student;
  final String senderName;
  const _StudentMessageTile(
      {required this.student, required this.senderName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student.fullName.isNotEmpty
                ? student.fullName[0].toUpperCase()
                : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${student.group} • ${student.email}'),
        trailing: IconButton(
          icon: const Icon(Icons.send_rounded),
          color: Theme.of(context).colorScheme.primary,
          tooltip: 'Хабарлама жіберу',
          onPressed: () => _showMessageForm(context, ref),
        ),
      ),
    );
  }

  Future<void> _showMessageForm(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${student.fullName} — хабарлама'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Тақырып'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Мазмұн'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Жіберу'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (titleCtrl.text.trim().isEmpty) return;

    await FirestoreSyncService().sendMessage(
      studentId: student.uid,
      title: titleCtrl.text.trim(),
      body: bodyCtrl.text.trim(),
      senderName: senderName,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${student.fullName} — хабарлама жіберілді ✓')),
      );
    }
  }
}
