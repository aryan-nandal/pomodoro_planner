import '../../domain/entities/pomodoro_session.dart';

class PomodoroSessionModel {
  final String id;
  final String? taskId;
  final int durationMinutes;
  final DateTime timestamp;
  final String type; // 'focus', 'shortBreak', 'longBreak'

  PomodoroSessionModel({
    required this.id,
    this.taskId,
    required this.durationMinutes,
    required this.timestamp,
    required this.type,
  });

  factory PomodoroSessionModel.fromEntity(PomodoroSession entity) {
    return PomodoroSessionModel(
      id: entity.id,
      taskId: entity.taskId,
      durationMinutes: entity.durationMinutes,
      timestamp: entity.timestamp,
      type: entity.type,
    );
  }

  PomodoroSession toEntity() {
    return PomodoroSession(
      id: id,
      taskId: taskId,
      durationMinutes: durationMinutes,
      timestamp: timestamp,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'durationMinutes': durationMinutes,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory PomodoroSessionModel.fromMap(Map<String, dynamic> map) {
    return PomodoroSessionModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String?,
      durationMinutes: map['durationMinutes'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String,
    );
  }
}
