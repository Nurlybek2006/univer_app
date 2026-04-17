import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';

/// Студент профилін басқару сервисі (SharedPreferences)
class ProfileService {
  static const String _profileKey = 'student_profile';

  /// Профильді жергілікті жадтан жүктеу
  Future<StudentProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StudentProfile.fromMap(map);
    }
    // Үлгі деректермен қайтару
    return StudentProfile(
      fullName: 'Аманов Арман Бекұлы',
      group: 'ИН-21-1',
      faculty: 'Физика-математика факультеті',
      course: 3,
      studentId: '2021001234',
      email: 'arman.amanov@student.kaznpu.kz',
      phone: '+7 (707) 123-45-67',
    );
  }

  /// Профильді жергілікті жадқа сақтау
  Future<void> saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(profile.toMap());
    await prefs.setString(_profileKey, jsonStr);
  }
}
