import 'package:equatable/equatable.dart';

class PomodoroSession extends Equatable {
  final String id;
  final String? taskId;
  final int durationMinutes;
  final DateTime timestamp;
  final String type; // 'focus', 'shortBreak', 'longBreak'

  const PomodoroSession({
    required this.id,
    this.taskId,
    required this.durationMinutes,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, taskId, durationMinutes, timestamp, type];
}
