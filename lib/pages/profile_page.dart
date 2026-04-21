import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../app/theme.dart';
import '../models/hive/user_hive_model.dart';
import '../core/firestore_sync_service.dart';
import '../providers/app_providers.dart';
import 'login_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  bool _saving = false;
  bool _uploadingPhoto = false;

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

  void _fillControllers(UserHiveModel p) {
    _nameController.text = p.fullName;
    _groupController.text = p.group;
    _facultyController.text = p.faculty;
    _courseController.text = p.course.toString();
    _studentIdController.text = p.studentId;
    _phoneController.text = p.phone;
  }

  // Суретті галерея/камерадан таңдап, жергілікті жадқа сақтау
  Future<void> _pickAndSavePhoto(UserHiveModel current) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Сурет қосу', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.photo_library_rounded, color: AppTheme.primary),
              ),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
              ),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source == null) return;

    final XFile? picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 600);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      // Суретті қолданба директориясына тұрақты сақтау
      final appDir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${appDir.path}/profile_photos');
      if (!await photoDir.exists()) await photoDir.create(recursive: true);
      final savedPath = '${photoDir.path}/${current.uid}.jpg';
      await File(picked.path).copy(savedPath);

      final updated = UserHiveModel(
        uid: current.uid, email: current.email, fullName: current.fullName,
        group: current.group, faculty: current.faculty, course: current.course,
        studentId: current.studentId, phone: current.phone, role: current.role,
        photoUrl: savedPath,
      );
      // Hive-ға сақтау (Firestore-ға жергілікті path сақтамаймыз)
      await FirestoreSyncService().updateUser(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль суреті сақталды ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _saveProfile(UserHiveModel current) async {
    setState(() => _saving = true);
    final updated = UserHiveModel(
      uid: current.uid, email: current.email,
      fullName: _nameController.text.trim(), group: _groupController.text.trim(),
      faculty: _facultyController.text.trim(),
      course: int.tryParse(_courseController.text.trim()) ?? current.course,
      studentId: _studentIdController.text.trim(), phone: _phoneController.text.trim(),
      role: current.role, photoUrl: current.photoUrl,
    );
    await FirestoreSyncService().updateUser(updated);
    setState(() { _saving = false; _isEditing = false; });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль сақталды ✓')));
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProvider);
    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (!_isEditing && _nameController.text.isEmpty && profile.fullName.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fillControllers(profile));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkBg
          : const Color(0xFFF0F2FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
                  Positioned(top: -30, right: -30, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)))),
                  Positioned(bottom: 30, left: -40, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withValues(alpha: 0.1)))),
                  Positioned(
                    bottom: 20, left: 0, right: 0,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 96, height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16)],
                              ),
                              child: ClipOval(child: _buildAvatar(profile)),
                            ),
                            if (_uploadingPhoto)
                              Container(
                                width: 96, height: 96,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.45)),
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: _uploadingPhoto ? null : () => _pickAndSavePhoto(profile),
                                child: Container(
                                  width: 30, height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: AppTheme.accent,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.5), blurRadius: 8)],
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(profile.fullName.isNotEmpty ? profile.fullName : '—',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(profile.group.isNotEmpty ? '${profile.group} • ${profile.course}-курс' : profile.email,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
                onPressed: () { _fillControllers(profile); setState(() => _isEditing = !_isEditing); },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                tooltip: 'Параметрлер',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _InfoCard(icon: Icons.email_outlined, label: 'Email', value: profile.email),
                  const SizedBox(height: 12),

                  // Хабарламалар батырмасы
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
                        child: const Icon(Icons.mail_outline_rounded, color: AppTheme.accent, size: 20),
                      ),
                      title: const Text('Хабарламалар', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Жеке хабарламаларды қараңыз', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage())),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text('Жеке деректер', style: Theme.of(context).textTheme.titleMedium),
                          ]),
                          const Divider(height: 24),
                          _buildField('Аты-жөні', _nameController, Icons.badge_outlined),
                          _buildField('Тобы', _groupController, Icons.groups_outlined),
                          _buildField('Факультет', _facultyController, Icons.school_outlined),
                          _buildField('Курс', _courseController, Icons.stairs_outlined, keyboardType: TextInputType.number),
                          _buildField('Студент ID', _studentIdController, Icons.credit_card_outlined),
                          _buildField('Телефон', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                        ],
                      ),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _saving ? null : () => _saveProfile(profile),
                      icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded),
                      label: const Text('Сақтау'),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserHiveModel profile) {
    final path = profile.photoUrl;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, width: 96, height: 96);
      }
    }
    return _defaultAvatar(profile);
  }

  Widget _defaultAvatar(UserHiveModel profile) => Container(
    color: AppTheme.primaryLight,
    child: Center(child: Text(
      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
    )),
  );

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _isEditing
          ? TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)))
          : Row(children: [
              Icon(icon, color: cs.primary, size: 18),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF6B7280))),
                Text(controller.text.isEmpty ? '—' : controller.text,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
              ])),
            ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primary.withValues(alpha: 0.15),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        title: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF6B7280))),
        subtitle: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
      ),
    );
  }
}