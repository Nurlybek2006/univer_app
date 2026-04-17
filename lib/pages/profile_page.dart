import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

/// Профиль беті — студент ақпаратын көрсету және өңдеу
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  StudentProfile? _profile;
  bool _isEditing = false;

  // Өңдеу контроллерлері
  late TextEditingController _nameController;
  late TextEditingController _groupController;
  late TextEditingController _facultyController;
  late TextEditingController _courseController;
  late TextEditingController _studentIdController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _groupController = TextEditingController();
    _facultyController = TextEditingController();
    _courseController = TextEditingController();
    _studentIdController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _facultyController.dispose();
    _courseController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    setState(() {
      _profile = profile;
      _fillControllers(profile);
    });
  }

  void _fillControllers(StudentProfile profile) {
    _nameController.text = profile.fullName;
    _groupController.text = profile.group;
    _facultyController.text = profile.faculty;
    _courseController.text = profile.course.toString();
    _studentIdController.text = profile.studentId;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    _profile!.fullName = _nameController.text.trim();
    _profile!.group = _groupController.text.trim();
    _profile!.faculty = _facultyController.text.trim();
    _profile!.course = int.tryParse(_courseController.text.trim()) ?? 1;
    _profile!.studentId = _studentIdController.text.trim();
    _profile!.email = _emailController.text.trim();
    _profile!.phone = _phoneController.text.trim();

    await _profileService.saveProfile(_profile!);

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль сақталды ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                _fillControllers(_profile!); // Өзгерістерді қайтару
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Аватар
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                _profile!.fullName.isNotEmpty
                    ? _profile!.fullName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_isEditing)
              Text(
                _profile!.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (!_isEditing)
              Text(
                '${_profile!.group} • ${_profile!.course}-курс',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 24),

            // Профиль өрістері
            _buildField('Аты-жөні', _nameController, Icons.person, colorScheme),
            _buildField('Тобы', _groupController, Icons.group, colorScheme),
            _buildField('Факультет', _facultyController, Icons.school, colorScheme),
            _buildField('Курс', _courseController, Icons.stairs, colorScheme,
                keyboardType: TextInputType.number),
            _buildField('Студент ID', _studentIdController, Icons.badge, colorScheme),
            _buildField('Email', _emailController, Icons.email, colorScheme,
                keyboardType: TextInputType.emailAddress),
            _buildField('Телефон', _phoneController, Icons.phone, colorScheme,
                keyboardType: TextInputType.phone),

            const SizedBox(height: 16),

            // Сақтау батырмасы
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Сақтау'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Профиль өрісі виджеті
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
              title: Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  )),
              subtitle: Text(
                controller.text.isNotEmpty ? controller.text : '—',
                style: const TextStyle(fontSize: 16),
              ),
              contentPadding: EdgeInsets.zero,
            ),
    );
  }
}
