import 'package:equatable/equatable.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final int completedTasksToday;
  final int totalTasksToday;
  final int focusMinutesToday;
  final List<int> focusMinutesLast7Days; // Last 7 days, index 0 is 6 days ago, index 6 is today
  final int dailyStreak;
  final int totalPomodorosCompleted;

  const StatsLoaded({
    required this.completedTasksToday,
    required this.totalTasksToday,
    required this.focusMinutesToday,
    required this.focusMinutesLast7Days,
    required this.dailyStreak,
    required this.totalPomodorosCompleted,
  });

  @override
  List<Object?> get props => [
        completedTasksToday,
        totalTasksToday,
        focusMinutesToday,
        focusMinutesLast7Days,
        dailyStreak,
        totalPomodorosCompleted,
      ];
}

class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
