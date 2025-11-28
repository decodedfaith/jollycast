import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jollycast/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Performance Test - Scrolling and Navigation', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'token': 'test_token', // Simulate logged in state
    });

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Measure Startup
    await binding.traceAction(() async {
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }, reportKey: 'startup_performance');

    // Wait for home screen
    expect(find.byType(Scaffold), findsWidgets);

    // Measure Scrolling Performance
    await binding.traceAction(() async {
      final listFinder = find.byType(ListView).first;
      if (listFinder.evaluate().isNotEmpty) {
        // Scroll down
        await tester.fling(listFinder, const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Scroll up
        await tester.fling(listFinder, const Offset(0, 500), 1000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'scrolling_performance');

    // Measure Navigation Performance
    await binding.traceAction(() async {
      final categoriesTab = find.text('Categories');
      if (categoriesTab.evaluate().isNotEmpty) {
        await tester.tap(categoriesTab);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'navigation_performance');
  });
}
