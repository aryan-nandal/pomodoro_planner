import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/domain/repositories/tasks_repository.dart';
import '../../../pomodoro/domain/repositories/pomodoro_repository.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final TasksRepository _tasksRepository;
  final PomodoroRepository _pomodoroRepository;

  StatsBloc({
    required TasksRepository tasksRepository,
    required PomodoroRepository pomodoroRepository,
  })  : _tasksRepository = tasksRepository,
        _pomodoroRepository = pomodoroRepository,
        super(StatsInitial()) {
    on<LoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final tasks = await _tasksRepository.getAllTasks();
      final sessions = await _pomodoroRepository.getSessions();

      final now = DateTime.now();
      final todayStr = _toDateString(now);

      // 1. Today's Tasks
      final todayTasks = tasks.where((t) => _toDateString(t.scheduledDate) == todayStr);
      final totalTasksToday = todayTasks.length;
      final completedTasksToday = todayTasks.where((t) => t.isCompleted).length;

      // 2. Today's Focus Minutes
      final focusSessions = sessions.where((s) => s.type == 'focus');
      final todaySessions = focusSessions.where((s) => _toDateString(s.timestamp) == todayStr);
      final focusMinutesToday = todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

      // 3. Weekly Focus Minutes (last 7 days)
      final weeklyFocus = List<int>.filled(7, 0);
      for (int i = 0; i < 7; i++) {
        final targetDate = now.subtract(Duration(days: 6 - i));
        final targetDateStr = _toDateString(targetDate);
        final daySessions = focusSessions.where((s) => _toDateString(s.timestamp) == targetDateStr);
        weeklyFocus[i] = daySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
      }

      // 4. Total Pomodoros
      final totalPomodorosCompleted = focusSessions.length;

      // 5. Daily Streak calculation
      final dailyStreak = _calculateStreak(tasks, sessions);

      emit(StatsLoaded(
        completedTasksToday: completedTasksToday,
        totalTasksToday: totalTasksToday,
        focusMinutesToday: focusMinutesToday,
        focusMinutesLast7Days: weeklyFocus,
        dailyStreak: dailyStreak,
        totalPomodorosCompleted: totalPomodorosCompleted,
      ));
    } catch (e) {
      emit(StatsError('Failed to compute stats: ${e.toString()}'));
    }
  }

  String _toDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _calculateStreak(List<dynamic> tasks, List<dynamic> sessions) {
    // Collect all dates that had activity (completed task or completed focus session)
    final activeDates = <String>{};

    for (final task in tasks) {
      if (task.isCompleted && task.completedAt != null) {
        activeDates.add(_toDateString(task.completedAt!));
      }
    }

    for (final session in sessions) {
      if (session.type == 'focus') {
        activeDates.add(_toDateString(session.timestamp));
      }
    }

    if (activeDates.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();
    final todayStr = _toDateString(checkDate);

    // If today is active, streak starts checking from today.
    // If today has no activity yet, we start checking from yesterday to see if streak is preserved.
    if (!activeDates.contains(todayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (activeDates.contains(_toDateString(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
