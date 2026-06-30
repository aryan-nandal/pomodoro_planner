import '../entities/pomodoro_session.dart';

abstract class PomodoroRepository {
  Future<List<PomodoroSession>> getSessions();
  Future<void> logSession(PomodoroSession session);
}
