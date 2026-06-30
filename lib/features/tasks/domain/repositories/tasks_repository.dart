import '../entities/task.dart';

abstract class TasksRepository {
  Future<List<Task>> getTasks(DateTime date);
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> searchTasks(String query);
  Future<List<Task>> getArchivedTasks();
  Future<List<Task>> getAllTasks();
}
