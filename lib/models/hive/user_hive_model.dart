import 'package:hive/hive.dart';

part 'user_hive_model.g.dart';

/// Пайдаланушы (student/admin) — Hive локалдық моделі
@HiveType(typeId: 0)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  late String uid;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String fullName;

  @HiveField(3)
  late String group;

  @HiveField(4)
  late String faculty;

  @HiveField(5)
  late int course;

  @HiveField(6)
  late String studentId;

  @HiveField(7)
  late String phone;

  @HiveField(8)
  late String role; // 'student' | 'admin'

  @HiveField(9)
  String? photoUrl;

  UserHiveModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.group,
    required this.faculty,
    required this.course,
    required this.studentId,
    required this.phone,
    required this.role,
    this.photoUrl,
  });

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'group': group,
        'faculty': faculty,
        'course': course,
        'studentId': studentId,
        'phone': phone,
        'role': role,
        'photoUrl': photoUrl,
      };

  factory UserHiveModel.fromFirestore(Map<String, dynamic> data) =>
      UserHiveModel(
        uid: data['uid'] ?? '',
        email: data['email'] ?? '',
        fullName: data['fullName'] ?? '',
        group: data['group'] ?? '',
        faculty: data['faculty'] ?? '',
        course: (data['course'] as num?)?.toInt() ?? 1,
        studentId: data['studentId'] ?? '',
        phone: data['phone'] ?? '',
        role: data['role'] ?? 'student',
        photoUrl: data['photoUrl'] as String?,
      );
}
