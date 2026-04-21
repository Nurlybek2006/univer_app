import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive/user_hive_model.dart';
import '../models/hive/schedule_hive_model.dart';
import '../models/hive/news_hive_model.dart';
import '../models/hive/quiz_hive_model.dart';
import '../models/hive/free_time_hive_model.dart';

/// Hive дерекқорын инициализациялау және адаптерлерді тіркеу
class HiveService {
  static const String usersBox = 'users';
  static const String scheduleBox = 'schedule';
  static const String newsBox = 'news';
  static const String quizBox = 'quiz';
  static const String freeTimeBox = 'freeTime';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Адаптерлерді тіркеу
    Hive.registerAdapter(UserHiveModelAdapter());
    Hive.registerAdapter(ScheduleHiveModelAdapter());
    Hive.registerAdapter(NewsHiveModelAdapter());
    Hive.registerAdapter(QuizQuestionHiveModelAdapter());
    Hive.registerAdapter(QuizCategoryHiveModelAdapter());
    Hive.registerAdapter(FreeTimeHiveModelAdapter());

    // Қораптарды ашу
    await Hive.openBox<UserHiveModel>(usersBox);
    await Hive.openBox<ScheduleHiveModel>(scheduleBox);
    await Hive.openBox<NewsHiveModel>(newsBox);
    await Hive.openBox<QuizCategoryHiveModel>(quizBox);
    await Hive.openBox<FreeTimeHiveModel>(freeTimeBox);
    await Hive.openBox(settingsBox); // параметрсіз — dynamic мәндер үшін
  }

  static Box<UserHiveModel> get users => Hive.box<UserHiveModel>(usersBox);
  static Box<ScheduleHiveModel> get schedule =>
      Hive.box<ScheduleHiveModel>(scheduleBox);
  static Box<NewsHiveModel> get news => Hive.box<NewsHiveModel>(newsBox);
  static Box<QuizCategoryHiveModel> get quiz =>
      Hive.box<QuizCategoryHiveModel>(quizBox);
  static Box<FreeTimeHiveModel> get freeTime =>
      Hive.box<FreeTimeHiveModel>(freeTimeBox);
  static Box get settings => Hive.box(settingsBox);
}
