import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hive/user_hive_model.dart';
import '../../providers/app_providers.dart';
import '../../core/firestore_sync_service.dart';

/// Admin: Студенттерді басқару беті
class AdminStudentsPage extends ConsumerStatefulWidget {
  const AdminStudentsPage({super.key});

  @override
  ConsumerState<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends ConsumerState<AdminStudentsPage> {
  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return Scaffold(
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Text('Студент жоқ. Жаңасын қосыңыз.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: students.length,
            itemBuilder: (ctx, i) => _StudentTile(student: students[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentForm(context, null),
        icon: const Icon(Icons.person_add),
        label: const Text('Студент қосу'),
      ),
    );
  }

  void _showStudentForm(BuildContext context, UserHiveModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StudentFormSheet(
        existing: existing,
        onSaved: () {
          ref.invalidate(allStudentsProvider);
        },
      ),
    );
  }
}

class _StudentTile extends ConsumerWidget {
  final UserHiveModel student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            student.fullName.isNotEmpty ? student.fullName[0] : '?',
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(student.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${student.group} • ${student.course}-курс'),
        trailing: PopupMenuButton<String>(
          onSelected: (action) async {
            if (action == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Жоюды растау'),
                  content: Text(
                      '${student.fullName} аккаунтын жою керек пе?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Жоқ'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Иә'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await FirestoreSyncService().deleteUser(student.uid);
                ref.invalidate(allStudentsProvider);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('Жою')),
          ],
        ),
      ),
    );
  }
}

/// Жаңа студент / өңдеу формасы
class _StudentFormSheet extends StatefulWidget {
  final UserHiveModel? existing;
  final VoidCallback onSaved;

  const _StudentFormSheet({this.existing, required this.onSaved});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.fullName ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.existing?.email ?? '');
  late final TextEditingController _password =
      TextEditingController(text: '');
  late final TextEditingController _group =
      TextEditingController(text: widget.existing?.group ?? '');
  late final TextEditingController _faculty =
      TextEditingController(text: widget.existing?.faculty ?? '');
  late final TextEditingController _course =
      TextEditingController(text: widget.existing?.course.toString() ?? '1');
  late final TextEditingController _studentId =
      TextEditingController(text: widget.existing?.studentId ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.existing?.phone ?? '');

  bool _saving = false;
  String? _error;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _group.dispose();
    _faculty.dispose();
    _course.dispose();
    _studentId.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final sync = FirestoreSyncService();
      if (_isNew) {
        // Firebase Auth-та жаңа аккаунт жасау
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        final user = UserHiveModel(
          uid: cred.user!.uid,
          email: _email.text.trim(),
          fullName: _name.text.trim(),
          group: _group.text.trim(),
          faculty: _faculty.text.trim(),
          course: int.tryParse(_course.text.trim()) ?? 1,
          studentId: _studentId.text.trim(),
          phone: _phone.text.trim(),
          role: 'student',
        );
        await sync.createUser(user);
      } else {
        final updated = UserHiveModel(
          uid: widget.existing!.uid,
          email: widget.existing!.email,
          fullName: _name.text.trim(),
          group: _group.text.trim(),
          faculty: _faculty.text.trim(),
          course: int.tryParse(_course.text.trim()) ?? 1,
          studentId: _studentId.text.trim(),
          phone: _phone.text.trim(),
          role: 'student',
        );
        await sync.updateUser(updated);
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Қате орын алды';
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isNew ? 'Жаңа студент қосу' : 'Студентті өңдеу',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _field(_name, 'Толық аты-жөні', Icons.person),
              if (_isNew) ...[
                _field(_email, 'Email', Icons.email,
                    type: TextInputType.emailAddress),
                _field(_password, 'Пароль', Icons.lock,
                    obscure: true),
              ],
              _field(_group, 'Топ (мыс: ИН-21-1)', Icons.group),
              _field(_faculty, 'Факультет', Icons.school),
              _field(_course, 'Курс', Icons.stairs,
                  type: TextInputType.number),
              _field(_studentId, 'Студент ID', Icons.badge),
              _field(_phone, 'Телефон', Icons.phone,
                  type: TextInputType.phone),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
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

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? type,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? '$label міндетті' : null,
      ),
    );
  }
}
