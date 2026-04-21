import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../login_page.dart';
import 'admin_messages_page.dart';
import 'admin_students_page.dart';
import 'admin_schedule_page.dart';
import 'admin_news_page.dart';
import 'admin_quiz_page.dart';

/// Admin Панелі — негізгі бет
class AdminPanelPage extends ConsumerStatefulWidget {
  const AdminPanelPage({super.key});

  @override
  ConsumerState<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends ConsumerState<AdminPanelPage> {
  int _selectedIndex = 0;

  final List<Widget> _sections = const [
    AdminStudentsPage(),
    AdminSchedulePage(),
    AdminNewsPage(),
    AdminQuizPage(),
    AdminMessagesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Панелі'),
        actions: [
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
      body: Row(
        children: [
          // Бүйірлік навигация (планшет/үлкен экран)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  admin?.fullName.isNotEmpty == true
                      ? admin!.fullName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Студенттер'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Кесте'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper),
                label: Text('Жаңалықтар'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(Icons.quiz),
                label: Text('Тест'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.send_outlined),
                selectedIcon: Icon(Icons.send),
                label: Text('Хабарлама'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _sections[_selectedIndex]),
        ],
      ),
    );
  }
}
