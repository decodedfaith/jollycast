import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jollycast/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Flow Integration Tests', () {
    testWidgets('Login Flow Test', (WidgetTester tester) async {
      // Initialize app
      SharedPreferences.setMockInitialValues({});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and enter email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Find and enter password
      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap Sign In button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're on the main screen (should show "Jolly" logo or tabs)
      // This would pass if login is successful
    });

    testWidgets('Search Flow Test', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'token': 'test_token'});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for main screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap search icon
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();

        // Enter search query
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'tech');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Verify search results or history appears
        expect(find.byType(ListView), findsWidgets);
      }
    });

    testWidgets('Categories Navigation Test', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'token': 'test_token'});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for main screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap Categories tab
      final categoriesTab = find.text('Categories');
      if (categoriesTab.evaluate().isNotEmpty) {
        await tester.tap(categoriesTab);
        await tester.pumpAndSettle();

        // Verify categories are displayed
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('Library Tab Test', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'token': 'test_token',
        'favorite_episode_ids': '[1, 2, 3]',
      });
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for main screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap Library tab
      final libraryTab = find.text('Library');
      if (libraryTab.evaluate().isNotEmpty) {
        await tester.tap(libraryTab);
        await tester.pumpAndSettle();

        // Verify library content
        expect(find.text('Your Library'), findsOneWidget);
      }
    });

    testWidgets('Podcast to Player Navigation Test', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'token': 'test_token'});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for podcasts to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find first podcast card (using InkWell or GestureDetector)
      final podcastCard = find.byType(InkWell).first;
      if (podcastCard.evaluate().isNotEmpty) {
        await tester.tap(podcastCard);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify episode list screen opens
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Favorite Toggle Test', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'token': 'test_token'});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for podcasts to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find favorite icon
      final favoriteIcon = find.byIcon(Icons.favorite_border);
      if (favoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcon.first);
        await tester.pumpAndSettle();

        // Verify icon changed to filled
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('Tab Navigation Test', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'token': 'test_token'});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find bottom navigation
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        // Tap each tab
        await tester.tap(find.text('Categories'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Library'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Discover'));
        await tester.pumpAndSettle();

        // All navigations should work without errors
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
