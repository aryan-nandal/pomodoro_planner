import 'package:flutter/foundation.dart' show kIsWeb, FlutterError;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/observability/app_bloc_observer.dart';
import 'core/observability/sentry_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/haptic_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'features/pomodoro/data/repositories/firestore_pomodoro_repository.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'features/statistics/presentation/bloc/stats_bloc.dart';
import 'features/statistics/presentation/bloc/stats_event.dart';
import 'features/tasks/domain/repositories/tasks_repository.dart';
import 'features/tasks/data/repositories/firestore_tasks_repository.dart';
import 'features/tasks/presentation/bloc/tasks_bloc.dart';
import 'features/tasks/presentation/bloc/tasks_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run app within Sentry wrapper for observability
  await SentryService.init(() async {
    // Set custom Bloc Observer for state transitions log
    Bloc.observer = AppBlocObserver();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Use emulator if specified via dart-define
    const useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
    if (useEmulator) {
      const host = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);

      // Log errors to stdout for E2E tests debugging
      FlutterError.onError = (FlutterErrorDetails details) {
        print('E2E_FLUTTER_ERROR: ${details.exception}\n${details.stack}');
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        print('E2E_PLATFORM_ERROR: $error\n$stack');
        return false;
      };
    }

    // Enable Firestore offline persistence for Web
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }

    // Instantiate and initialize Core services
    final audioService = AudioService();
    final hapticService = HapticService();
    final notificationService = NotificationService();
    await notificationService.init();

    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AudioService>.value(value: audioService),
          RepositoryProvider<HapticService>.value(value: hapticService),
          RepositoryProvider<NotificationService>.value(value: notificationService),
        ],
        child: BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AppStarted()),
          child: const MyApp(),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          final tasksRepository = FirestoreTasksRepository(
            FirebaseFirestore.instance,
            authState.user.uid,
          );
          final pomodoroRepository = FirestorePomodoroRepository(
            FirebaseFirestore.instance,
            authState.user.uid,
          );

          return MultiRepositoryProvider(
            key: ValueKey(authState.user.uid),
            providers: [
              RepositoryProvider<TasksRepository>.value(value: tasksRepository),
              RepositoryProvider<PomodoroRepository>.value(value: pomodoroRepository),
            ],
            child: MultiBlocProvider(
              key: ValueKey(authState.user.uid),
              providers: [
                BlocProvider<TasksBloc>(
                  create: (context) => TasksBloc(
                    repository: tasksRepository,
                    audioService: context.read<AudioService>(),
                    hapticService: context.read<HapticService>(),
                  )..add(LoadTasks(DateTime.now())),
                ),
                BlocProvider<PomodoroBloc>(
                  create: (context) => PomodoroBloc(
                    repository: pomodoroRepository,
                    audioService: context.read<AudioService>(),
                    hapticService: context.read<HapticService>(),
                    notificationService: context.read<NotificationService>(),
                  ),
                ),
                BlocProvider<StatsBloc>(
                  create: (context) => StatsBloc(
                    tasksRepository: tasksRepository,
                    pomodoroRepository: pomodoroRepository,
                  )..add(LoadStats()),
                ),
              ],
              child: MaterialApp(
                title: 'Task Planner & Pomodoro',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                home: const AuthGate(),
              ),
            ),
          );
        }

        // Unauthenticated or loading state: show AuthGate directly
        return MaterialApp(
          title: 'Task Planner & Pomodoro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AuthGate(),
        );
      },
    );
  }
}
