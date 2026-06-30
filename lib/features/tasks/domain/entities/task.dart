import 'package:equatable/equatable.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

class Category extends Equatable {
  final String id;
  final String name;
  final int colorHex;
  final String iconName;

  const Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, name, colorHex, iconName];
}

class Subtask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final Category? category;
  final TaskPriority priority;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final List<Subtask> subtasks;
  final String recurrencePattern; // 'none', 'daily', 'weekly'
  final DateTime scheduledDate;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.priority,
    this.startTime,
    this.endTime,
    required this.isCompleted,
    required this.subtasks,
    required this.recurrencePattern,
    required this.scheduledDate,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Category? category,
    TaskPriority? priority,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    List<Subtask>? subtasks,
    String? recurrencePattern,
    DateTime? scheduledDate,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        priority,
        startTime,
        endTime,
        isCompleted,
        subtasks,
        recurrencePattern,
        scheduledDate,
        completedAt,
      ];
}
