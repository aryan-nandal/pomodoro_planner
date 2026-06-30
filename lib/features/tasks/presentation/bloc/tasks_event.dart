import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TasksEvent {
  final DateTime date;

  const LoadTasks(this.date);

  @override
  List<Object?> get props => [date];
}

class AddTask extends TasksEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TasksEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TasksEvent {
  final String id;
  final DateTime date; // To reload tasks for that day after delete

  const DeleteTask(this.id, this.date);

  @override
  List<Object?> get props => [id, date];
}

class ToggleSubtask extends TasksEvent {
  final String taskId;
  final String subtaskId;
  final DateTime date;

  const ToggleSubtask(this.taskId, this.subtaskId, this.date);

  @override
  List<Object?> get props => [taskId, subtaskId, date];
}

class SearchTasksEvent extends TasksEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadArchive extends TasksEvent {}
