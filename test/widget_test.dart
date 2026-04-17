import 'package:flutter_test/flutter_test.dart';
import 'package:univer_app/main.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentAssistantApp());
    // Төменгі навигация бар екенін тексеру
    expect(find.text('AI Көмекші'), findsOneWidget);
    expect(find.text('Кесте'), findsOneWidget);
    expect(find.text('Жаңалықтар'), findsOneWidget);
  });
}
