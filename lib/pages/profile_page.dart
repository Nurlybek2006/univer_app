import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/user_hive_model.dart';
import '../core/firestore_sync_service.dart';
import '../providers/app_providers.dart';
import 'login_page.dart';

/// Профиль беті — студент ақпаратын көрсету және өңдеу
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  bool _saving = false;

  late TextEditingController _nameController;
  late TextEditingController _groupController;
  late TextEditingController _facultyController;
  late TextEditingController _courseController;
  late TextEditingController _studentIdController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _groupController = TextEditingController();
    _facultyController = TextEditingController();
    _courseController = TextEditingController();
    _studentIdController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _facultyController.dispose();
    _courseController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fillControllers(UserHiveModel profile) {
    _nameController.text = profile.fullName;
    _groupController.text = profile.group;
    _facultyController.text = profile.faculty;
    _courseController.text = profile.course.toString();
    _studentIdController.text = profile.studentId;
    _phoneController.text = profile.phone;
  }

  Future<void> _saveProfile(UserHiveModel current) async {
    setState(() => _saving = true);
    final updated = UserHiveModel(
      uid: current.uid,
      email: current.email,
      fullName: _nameController.text.trim(),
      group: _groupController.text.trim(),
      faculty: _facultyController.text.trim(),
      course: int.tryParse(_courseController.text.trim()) ?? current.course,
      studentId: _studentIdController.text.trim(),
      phone: _phoneController.text.trim(),
      role: current.role,
    );
    await FirestoreSyncService().updateUser(updated);
    setState(() {
      _saving = false;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль сақталды ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = ref.watch(currentUserProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Бірінші рет жүктелгенде өрістерді толтыру
    if (!_isEditing &&
        _nameController.text.isEmpty &&
        profile.fullName.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillControllers(profile);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Болдырмау' : 'Өңдеу',
            onPressed: () {
              if (_isEditing) {
                _fillControllers(profile);
              } else {
                _fillControllers(profile);
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Шығу',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                profile.fullName.isNotEmpty
                    ? profile.fullName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_isEditing) ...[
              Text(
                profile.fullName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${profile.group} • ${profile.course}-курс',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 24),
            _buildField('Аты-жөні', _nameController, Icons.person, colorScheme),
            _buildField('Тобы', _groupController, Icons.group, colorScheme),
            _buildField('Факультет', _facultyController, Icons.school, colorScheme),
            _buildField('Курс', _courseController, Icons.stairs, colorScheme,
                keyboardType: TextInputType.number),
            _buildField('Студент ID', _studentIdController, Icons.badge, colorScheme),
            _buildField('Телефон', _phoneController, Icons.phone, colorScheme,
                keyboardType: TextInputType.phone),
            // Email өңдеуге жатпайды
            ListTile(
              leading: Icon(Icons.email, color: colorScheme.primary),
              title: const Text('Email'),
              subtitle: Text(profile.email),
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : () => _saveProfile(profile),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Сақтау'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    ColorScheme colorScheme, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _isEditing
          ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
              ),
            )
          : ListTile(
              leading: Icon(icon, color: colorScheme.primary),
              title: Text(label),
              subtitle: Text(controller.text.isEmpty ? '—' : controller.text),
            ),
    );
  }
}