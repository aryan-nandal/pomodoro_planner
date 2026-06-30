import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> tasks;
  final DateTime selectedDate;
  final List<Task> searchResults;
  final List<Task> archivedTasks;
  final String? error;

  const TasksLoaded({
    required this.tasks,
    required this.selectedDate,
    this.searchResults = const [],
    this.archivedTasks = const [],
    this.error,
  });

  TasksLoaded copyWith({
    List<Task>? tasks,
    DateTime? selectedDate,
    List<Task>? searchResults,
    List<Task>? archivedTasks,
    String? error,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      selectedDate: selectedDate ?? this.selectedDate,
      searchResults: searchResults ?? this.searchResults,
      archivedTasks: archivedTasks ?? this.archivedTasks,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tasks, selectedDate, searchResults, archivedTasks, error];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}
