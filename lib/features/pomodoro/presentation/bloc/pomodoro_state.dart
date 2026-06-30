import 'package:equatable/equatable.dart';
import '../../../tasks/domain/entities/task.dart';

enum PomodoroStatus { idle, running, paused, completed }
enum PomodoroType { focus, shortBreak, longBreak }

class PomodoroState extends Equatable {
  final int secondsRemaining;
  final int totalSeconds;
  final PomodoroStatus status;
  final PomodoroType type;
  final Task? selectedTask;
  final int completedCycles;
  
  // Custom durations in minutes
  final int focusDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;

  const PomodoroState({
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.status,
    required this.type,
    this.selectedTask,
    required this.completedCycles,
    this.focusDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
  });

  factory PomodoroState.initial() {
    const focusSecs = 25 * 60;
    return const PomodoroState(
      secondsRemaining: focusSecs,
      totalSeconds: focusSecs,
      status: PomodoroStatus.idle,
      type: PomodoroType.focus,
      completedCycles: 0,
    );
  }

  PomodoroState copyWith({
    int? secondsRemaining,
    int? totalSeconds,
    PomodoroStatus? status,
    PomodoroType? type,
    Task? Function()? selectedTask,
    int? completedCycles,
    int? focusDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
  }) {
    return PomodoroState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      status: status ?? this.status,
      type: type ?? this.type,
      selectedTask: selectedTask != null ? selectedTask() : this.selectedTask,
      completedCycles: completedCycles ?? this.completedCycles,
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      shortBreakDurationMinutes: shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes: longBreakDurationMinutes ?? this.longBreakDurationMinutes,
    );
  }

  @override
  List<Object?> get props => [
        secondsRemaining,
        totalSeconds,
        status,
        type,
        selectedTask,
        completedCycles,
        focusDurationMinutes,
        shortBreakDurationMinutes,
        longBreakDurationMinutes,
      ];
}
