import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../models/task_model.dart';

class FirestoreTasksRepository implements TasksRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirestoreTasksRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  @override
  Future<List<Task>> getTasks(DateTime date) async {
    final snapshot = await _tasksCollection.get();
    final all = snapshot.docs.map((doc) => TaskModel.fromMap(doc.data()).toEntity()).toList();
    final filtered = all.where((task) {
      final sd = task.scheduledDate;
      return sd.year == date.year && sd.month == date.month && sd.day == date.day;
    }).toList();

    filtered.sort((a, b) {
      if (a.startTime != null && b.startTime != null) {
        return a.startTime!.compareTo(b.startTime!);
      } else if (a.startTime != null) {
        return -1;
      } else if (b.startTime != null) {
        return 1;
      }
      return b.priority.index.compareTo(a.priority.index);
    });
    return filtered;
  }

  @override
  Future<void> saveTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _tasksCollection.doc(task.id).set(model.toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    final snapshot = await _tasksCollection.get();
    final all = snapshot.docs.map((doc) => TaskModel.fromMap(doc.data()).toEntity()).toList();
    return all.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             task.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<Task>> getArchivedTasks() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final snapshot = await _tasksCollection.get();
    final all = snapshot.docs.map((doc) => TaskModel.fromMap(doc.data()).toEntity()).toList();
    return all.where((task) {
      return task.scheduledDate.isBefore(startOfToday);
    }).toList();
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final snapshot = await _tasksCollection.get();
    return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data()).toEntity()).toList();
  }
}
