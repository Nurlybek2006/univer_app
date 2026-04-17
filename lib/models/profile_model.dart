/// Студент профилінің моделі
class StudentProfile {
  String fullName;   // Толық аты-жөні
  String group;      // Тобы
  String faculty;    // Факультет
  int course;        // Курс
  String studentId;  // Студент ID
  String email;      // Электрондық пошта
  String phone;      // Телефон

  StudentProfile({
    this.fullName = '',
    this.group = '',
    this.faculty = '',
    this.course = 1,
    this.studentId = '',
    this.email = '',
    this.phone = '',
  });

  /// SharedPreferences-ке сақтау үшін Map-ке түрлендіру
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'group': group,
      'faculty': faculty,
      'course': course,
      'studentId': studentId,
      'email': email,
      'phone': phone,
    };
  }

  /// Map-тен профиль жасау
  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      fullName: map['fullName'] ?? '',
      group: map['group'] ?? '',
      faculty: map['faculty'] ?? '',
      course: map['course'] ?? 1,
      studentId: map['studentId'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
