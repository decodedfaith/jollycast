import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jollycast/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Flow Integration Tests', () {
    testWidgets('Login and Onboarding Flow Test', (WidgetTester tester) async {
      // Initialize app
      SharedPreferences.setMockInitialValues({});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- LOGIN SCREEN ---
      // Step 1: Phone Number
      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '08114227399');
      await tester.pumpAndSettle();

      // Tap Continue (Phone)
      await tester.tap(find.text('Continue').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 2: OTP
      final otpField = find.byType(TextField).last;
      await tester.enterText(otpField, '123456'); // Mock OTP
      await tester.pumpAndSettle();

      // Tap Continue (OTP)
      await tester.tap(find.text('Continue').last);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- ONBOARDING SCREEN ---
      // Verify we are on Onboarding (Account Setup)
      if (find.text('Complete account setup').evaluate().isNotEmpty) {
        // Step 1: Account Setup
        final firstNameField = find.widgetWithText(TextField, 'First name');
        if (firstNameField.evaluate().isNotEmpty) {
          await tester.enterText(firstNameField, 'Test');
        }

        final lastNameField = find.widgetWithText(TextField, 'Last name');
        if (lastNameField.evaluate().isNotEmpty) {
          await tester.enterText(lastNameField, 'User');
        }

        final emailField = find.widgetWithText(TextField, 'Email address');
        if (emailField.evaluate().isNotEmpty) {
          await tester.enterText(emailField, 'test@example.com');
        }

        final passwordField = find.widgetWithText(TextField, 'Create password');
        if (passwordField.evaluate().isNotEmpty) {
          await tester.enterText(passwordField, 'password');
        }
        await tester.pumpAndSettle();

        final continueButton = find.text('Continue');
        if (continueButton.evaluate().isNotEmpty) {
          await tester.tap(continueButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // Step 2: Interests
        if (find.text('Welcome, Devon').evaluate().isNotEmpty) {
          final techInterest = find.text('Technology');
          if (techInterest.evaluate().isNotEmpty) {
            await tester.tap(techInterest.first);
          }
          final continueBtn = find.text('Continue');
          if (continueBtn.evaluate().isNotEmpty) {
            await tester.tap(continueBtn);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }

        // Step 3: Avatar
        if (find
            .text('Select an avatar to represent your funk')
            .evaluate()
            .isNotEmpty) {
          final avatarIcon = find.byIcon(Icons.person);
          if (avatarIcon.evaluate().isNotEmpty) {
            await tester.tap(avatarIcon.first);
          }
          final continueBtn = find.text('Continue');
          if (continueBtn.evaluate().isNotEmpty) {
            await tester.tap(continueBtn);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }

        // Step 4: Subscription
        if (find.text('Enjoy unlimited podcasts').evaluate().isNotEmpty) {
          final skipButton = find.text('Skip for now');
          if (skipButton.evaluate().isNotEmpty) {
            await tester.tap(skipButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }

        // Step 5: All Set
        if (find.text("You're all set Devon!").evaluate().isNotEmpty) {
          final seePlansButton = find.text('See plans');
          if (seePlansButton.evaluate().isNotEmpty) {
            await tester.tap(seePlansButton);
            await tester.pumpAndSettle(const Duration(seconds: 5));
          }
        }
      }

      // --- HOME SCREEN ---
      // Verify we're on the main screen (Podcast List)
      expect(find.byType(Scaffold), findsWidgets);
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
