import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pomodoro_planner/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tasks Flow E2E Test', () {
    testWidgets('Load seeded tasks, complete task, and create a new task', (WidgetTester tester) async {
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

      // Sign In with the seeded account
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      final signInBtn = find.ancestor(
        of: find.text('Sign In'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(signInBtn);
      
      // Wait for authentication and data load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      // 2. Verify that seeded tasks are loaded and visible
      await binding.takeScreenshot('tasks_flow/01_tasks_loaded');
      
      expect(find.text('Incomplete Seed Task'), findsOneWidget);
      expect(find.text('Completed Seed Task'), findsOneWidget);

      // 3. Mark the incomplete task as completed
      final taskRow = find.ancestor(
        of: find.text('Incomplete Seed Task'),
        matching: find.byType(Row),
      ).last;
      final checkbox = find.descendant(
        of: taskRow,
        matching: find.byType(GestureDetector),
      ).first;

      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      
      // Wait for firestore write
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await binding.takeScreenshot('tasks_flow/02_task_completed');

      // 4. Tap the FAB to create a new task
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we are on Create Task screen
      expect(find.text('Create Task'), findsOneWidget);
      await binding.takeScreenshot('tasks_flow/03_create_task_screen');

      // Enter task title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'New E2E Task');
      await tester.pumpAndSettle();

      // Tap Save
      final saveBtn = find.text('Save');
      await tester.tap(saveBtn);
      
      // Wait for navigation and database write
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      // 5. Verify the new task is in the list
      await binding.takeScreenshot('tasks_flow/04_new_task_in_list');
      expect(find.text('New E2E Task'), findsOneWidget);
    });
  });
}
