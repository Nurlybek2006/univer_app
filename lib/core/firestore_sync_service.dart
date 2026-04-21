import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hive/user_hive_model.dart';
import '../models/hive/schedule_hive_model.dart';
import '../models/hive/news_hive_model.dart';
import '../models/hive/quiz_hive_model.dart';
import '../models/hive/free_time_hive_model.dart';
import '../services/notification_service.dart';
import 'hive_service.dart';

/// Firestore → Hive синхрондау сервисі
class FirestoreSyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────── USERS ────────────────────────────

  /// Firestore-дан бір пайдаланушыны жүктеп Hive-ге сақтау
  Future<UserHiveModel?> fetchAndCacheUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final model = UserHiveModel.fromFirestore(doc.data()!);
      HiveService.users.put(uid, model);
      return model;
    } catch (_) {
      return HiveService.users.get(uid);
    }
  }

  /// Жаңа пайдаланушыны Firestore-ға қосу
  Future<void> createUser(UserHiveModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
    HiveService.users.put(user.uid, user);
  }

  /// Пайдаланушыны жаңарту
  Future<void> updateUser(UserHiveModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toFirestore());
    HiveService.users.put(user.uid, user);
  }

  /// Барлық студенттерді жүктеу (Admin панелі үшін)
  Future<List<UserHiveModel>> fetchAllStudents() async {
    try {
      final snap = await _db
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      final students = snap.docs
          .map((d) => UserHiveModel.fromFirestore(d.data()))
          .toList();
      for (final s in students) {
        HiveService.users.put(s.uid, s);
      }
      return students;
    } catch (_) {
      return HiveService.users.values
          .where((u) => u.role == 'student')
          .toList();
    }
  }

  /// Студент аккаунтын жою (Firestore тарапынан ғана жойылады)
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
    HiveService.users.delete(uid);
  }

  // ──────────────────────────── SCHEDULE ────────────────────────────

  /// Кестені синхрондау
  Future<void> syncSchedule() async {
    try {
      final snap = await _db.collection('schedules').get();
      final box = HiveService.schedule;
      await box.clear();
      for (final doc in snap.docs) {
        final model = ScheduleHiveModel.fromFirestore(doc.id, doc.data());
        box.put(doc.id, model);
      }
    } catch (_) {
      // Офлайн режим — Hive кэшін қолдан
    }
  }

  Future<List<ScheduleHiveModel>> getSchedule() async {
    await syncSchedule();
    return HiveService.schedule.values.toList();
  }

  Future<void> addScheduleItem(ScheduleHiveModel item) async {
    final ref = await _db.collection('schedules').add(item.toFirestore());
    item.id = ref.id;
    HiveService.schedule.put(ref.id, item);
  }

  Future<void> updateScheduleItem(ScheduleHiveModel item) async {
    await _db.collection('schedules').doc(item.id).update(item.toFirestore());
    HiveService.schedule.put(item.id, item);
  }

  Future<void> deleteScheduleItem(String id) async {
    await _db.collection('schedules').doc(id).delete();
    HiveService.schedule.delete(id);
  }

  // ──────────────────────────── NEWS ────────────────────────────

  Future<void> syncNews() async {
    try {
      final snap = await _db
          .collection('news')
          .orderBy('date', descending: true)
          .get();
      final box = HiveService.news;
      await box.clear();
      for (final doc in snap.docs) {
        final model = NewsHiveModel.fromFirestore(doc.id, doc.data());
        box.put(doc.id, model);
      }
    } catch (_) {}
  }

  Future<List<NewsHiveModel>> getNews() async {
    await syncNews();
    final list = HiveService.news.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> addNews(NewsHiveModel item) async {
    final ref = await _db.collection('news').add(item.toFirestore());
    item.id = ref.id;
    HiveService.news.put(ref.id, item);
  }

  Future<void> updateNews(NewsHiveModel item) async {
    await _db.collection('news').doc(item.id).update(item.toFirestore());
    HiveService.news.put(item.id, item);
  }

  Future<void> deleteNews(String id) async {
    await _db.collection('news').doc(id).delete();
    HiveService.news.delete(id);
  }

  // ──────────────────────────── QUIZ ────────────────────────────

  Future<void> syncQuiz() async {
    try {
      final snap = await _db.collection('quizzes').get();
      final box = HiveService.quiz;
      await box.clear();
      for (final doc in snap.docs) {
        final model = QuizCategoryHiveModel.fromFirestore(doc.id, doc.data());
        box.put(doc.id, model);
      }
    } catch (_) {}
  }

  Future<List<QuizCategoryHiveModel>> getQuizCategories() async {
    await syncQuiz();
    return HiveService.quiz.values.toList();
  }

  Future<void> addQuizCategory(QuizCategoryHiveModel item) async {
    final ref = await _db.collection('quizzes').add(item.toFirestore());
    item.id = ref.id;
    HiveService.quiz.put(ref.id, item);
  }

  Future<void> updateQuizCategory(QuizCategoryHiveModel item) async {
    await _db.collection('quizzes').doc(item.id).update(item.toFirestore());
    HiveService.quiz.put(item.id, item);
  }

  Future<void> deleteQuizCategory(String id) async {
    await _db.collection('quizzes').doc(id).delete();
    HiveService.quiz.delete(id);
  }

  // ──────────────────────────── FREE TIME ────────────────────────────

  Future<void> syncFreeTime() async {
    try {
      final snap = await _db.collection('free_time_suggestions').get();
      final box = HiveService.freeTime;
      await box.clear();
      for (final doc in snap.docs) {
        final model = FreeTimeHiveModel.fromFirestore(doc.id, doc.data());
        box.put(doc.id, model);
      }
    } catch (_) {}
  }

  Future<List<FreeTimeHiveModel>> getFreeTimeSuggestions(String level) async {
    await syncFreeTime();
    return HiveService.freeTime.values
        .where((f) => f.level == level)
        .toList();
  }

  Future<void> addFreeTimeSuggestion(FreeTimeHiveModel item) async {
    final ref = await _db.collection('free_time_suggestions').add(item.toFirestore());
    item.id = ref.id;
    HiveService.freeTime.put(ref.id, item);
  }

  Future<void> deleteFreeTimeSuggestion(String id) async {
    await _db.collection('free_time_suggestions').doc(id).delete();
    HiveService.freeTime.delete(id);
  }

  // ──────────────────────────── MESSAGES ────────────────────────────

  /// Admin → белгілі бір студентке жеке хабарлама жіберу
  Future<void> sendMessage({
    required String studentId,
    required String title,
    required String body,
    required String senderName,
  }) async {
    await _db.collection('messages').add({
      'studentId': studentId,
      'title': title,
      'body': body,
      'sender': senderName,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // ──────────────────────────── NOTIFICATIONS ────────────────────────────

  /// Жергілікті хабарламаны көрсету (Firestore-сыз жылдам хабарлама)
  Future<void> triggerLocalNotification({
    required String title,
    required String body,
  }) async {
    await NotificationService().showNotification(title: title, body: body);
  }
}
