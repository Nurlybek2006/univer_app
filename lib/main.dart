import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme.dart';
import 'core/hive_service.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/admin/admin_panel_page.dart';
import 'providers/app_providers.dart';
import 'services/notification_service.dart';
// TODO: ФлуттерФайр CLI арқылы жасалған файл: `flutterfire configure`
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveService.init();
  await NotificationService().init();
  runApp(const ProviderScope(child: StudentAssistantApp()));
}

/// Студент Көмекшісі — негізгі қосымша
class StudentAssistantApp extends ConsumerWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);

    // Сессия жүктелуін күту (restoreSession async)
    Widget home;
    if (auth.isLoading) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (auth.currentUser == null) {
      home = const LoginPage();
    } else if (auth.currentUser!.role == 'admin') {
      home = const AdminPanelPage();
    } else {
      home = const HomePage();
    }

    return MaterialApp(
      title: 'Студент Көмекшісі',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      home: home,
    );
  }
}

