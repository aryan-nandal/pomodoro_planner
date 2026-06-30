import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pomodoro_planner/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow E2E Test', () {
    testWidgets('Sign Up and Navigate to Home Screen', (WidgetTester tester) async {
      // 1. Boot up the app
      app.main();
      // Wait for AuthGate to transition from loading/initial to AuthScreen (Firebase Auth init is async)
      bool loaded = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('Tasker').evaluate().isNotEmpty) {
          loaded = true;
          break;
        }
      }
      expect(loaded, isTrue, reason: 'App did not load AuthScreen in time');
      await tester.pumpAndSettle();

      // Take initial screenshot of Sign In page
      await binding.takeScreenshot('auth_flow/01_auth_screen');
      expect(find.text('Tasker'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // 2. Tap toggle button to go to Sign Up screen
      final signUpToggle = find.text("Don't have an account? Sign Up");
      expect(signUpToggle, findsOneWidget);
      await tester.tap(signUpToggle);
      await tester.pumpAndSettle();

      // Take screenshot of Sign Up page
      await binding.takeScreenshot('auth_flow/02_signup_screen');
      expect(find.text('Sign Up'), findsOneWidget);

      // 3. Find input fields
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      // Enter signup details
      final randomEmail = 'e2e-tester-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await tester.enterText(emailField, randomEmail);
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // 4. Tap the Sign Up button
      final signUpBtn = find.ancestor(
        of: find.text('Sign Up'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(signUpBtn);
      
      // Wait for Auth and Firestore operations to complete and navigate to Home
      // Use multiple pump calls as Firebase operations are asynchronous
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      // Take screenshot of Home page after signup
      await binding.takeScreenshot('auth_flow/03_home_screen_after_signup');

      // Verify that we are on the Home screen (which should show user profile elements or task planner)
      // Since it's a new user, there should be no tasks, but the home layout should be loaded.
      // Let's verify we don't see the Auth screen anymore
      expect(find.text('Tasker'), findsNothing);
      expect(find.text('Sign In'), findsNothing);
      expect(find.text('Sign Up'), findsNothing);
    });
  });
}
