import 'package:equatable/equatable.dart';
import '../../../tasks/domain/entities/task.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends PomodoroEvent {}

class PauseTimer extends PomodoroEvent {}

class ResetTimer extends PomodoroEvent {}

class SkipTimer extends PomodoroEvent {}

class TimerTicked extends PomodoroEvent {
  final int secondsRemaining;

  const TimerTicked(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

class SelectFocusTask extends PomodoroEvent {
  final Task? task;

  const SelectFocusTask(this.task);

  @override
  List<Object?> get props => [task];
}

class SetCustomDurations extends PomodoroEvent {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  const SetCustomDurations({
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
  });

  @override
  List<Object?> get props => [focusMinutes, shortBreakMinutes, longBreakMinutes];
}
