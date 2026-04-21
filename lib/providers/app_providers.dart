import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth_service.dart';
import '../core/firestore_sync_service.dart';
import '../core/hive_service.dart';
import '../models/hive/user_hive_model.dart';
import '../models/hive/schedule_hive_model.dart';
import '../models/hive/news_hive_model.dart';
import '../models/hive/quiz_hive_model.dart';
import '../models/hive/free_time_hive_model.dart';

// ─── Тақырып провайдері ───────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_load());

  static ThemeMode _load() {
    final isDark =
        HiveService.settings.get('darkMode', defaultValue: false) as bool;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => state == ThemeMode.dark;

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    HiveService.settings.put('darkMode', next == ThemeMode.dark);
    state = next;
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

// ─── Хабарландырулар провайдері ────────────────────────────────────

class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier()
      : super(
            HiveService.settings.get('notifications', defaultValue: true)
                as bool);

  void toggle() {
    final next = !state;
    HiveService.settings.put('notifications', next);
    state = next;
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, bool>(
        (ref) => NotificationsNotifier());

// ─── Негізгі сервистер ───────────────────────────────────────────

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  final service = AuthService();
  service.restoreSession();
  return service;
});

final firestoreSyncProvider = Provider<FirestoreSyncService>((ref) {
  return FirestoreSyncService();
});

// ─── Auth күйі ───────────────────────────────────────────────────

final currentUserProvider = Provider<UserHiveModel?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).isAdmin;
});

// ─── Кесте провайдері ─────────────────────────────────────────────

final scheduleProvider =
    FutureProvider<List<ScheduleHiveModel>>((ref) async {
  final sync = ref.read(firestoreSyncProvider);
  return sync.getSchedule();
});

// ─── Жаңалықтар провайдері ────────────────────────────────────────

final newsProvider =
    FutureProvider<List<NewsHiveModel>>((ref) async {
  final sync = ref.read(firestoreSyncProvider);
  return sync.getNews();
});

// ─── Тест санаттары провайдері ────────────────────────────────────

final quizProvider =
    FutureProvider<List<QuizCategoryHiveModel>>((ref) async {
  final sync = ref.read(firestoreSyncProvider);
  return sync.getQuizCategories();
});

// ─── Бос уақыт ұсыныстары провайдері ─────────────────────────────

final freeTimeLevelProvider = StateProvider<String>((ref) => 'medium');

final freeTimeSuggestionsProvider =
    FutureProvider<List<FreeTimeHiveModel>>((ref) async {
  final level = ref.watch(freeTimeLevelProvider);
  final sync = ref.read(firestoreSyncProvider);
  return sync.getFreeTimeSuggestions(level);
});

// ─── Студенттер тізімі (Admin) ────────────────────────────────────

final allStudentsProvider =
    FutureProvider<List<UserHiveModel>>((ref) async {
  final sync = ref.read(firestoreSyncProvider);
  return sync.fetchAllStudents();
});
