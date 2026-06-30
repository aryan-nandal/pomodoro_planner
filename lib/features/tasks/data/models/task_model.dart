import '../../domain/entities/task.dart';

class CategoryModel {
  final String id;
  final String name;
  final int colorHex;
  final String iconName;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
  });

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      colorHex: colorHex,
      iconName: iconName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconName': iconName,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['colorHex'] as int,
      iconName: map['iconName'] as String,
    );
  }
}

class SubtaskModel {
  final String id;
  final String title;
  final bool isCompleted;

  SubtaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory SubtaskModel.fromEntity(Subtask entity) {
    return SubtaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }

  Subtask toEntity() {
    return Subtask(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final CategoryModel? category;
  final int priorityIndex; // 0 = low, 1 = medium, 2 = high
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final List<SubtaskModel> subtasks;
  final String recurrencePattern; // 'none', 'daily', 'weekly'
  final DateTime scheduledDate;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.priorityIndex,
    this.startTime,
    this.endTime,
    required this.isCompleted,
    required this.subtasks,
    required this.recurrencePattern,
    required this.scheduledDate,
    this.completedAt,
  });

  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category != null ? CategoryModel.fromEntity(entity.category!) : null,
      priorityIndex: entity.priority.index,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isCompleted: entity.isCompleted,
      subtasks: entity.subtasks.map((s) => SubtaskModel.fromEntity(s)).toList(),
      recurrencePattern: entity.recurrencePattern,
      scheduledDate: entity.scheduledDate,
      completedAt: entity.completedAt,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      category: category?.toEntity(),
      priority: TaskPriority.values[priorityIndex],
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
      subtasks: subtasks.map((s) => s.toEntity()).toList(),
      recurrencePattern: recurrencePattern,
      scheduledDate: scheduledDate,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category?.toMap(),
      'priorityIndex': priorityIndex,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'recurrencePattern': recurrencePattern,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] != null
          ? CategoryModel.fromMap(Map<String, dynamic>.from(map['category']))
          : null,
      priorityIndex: map['priorityIndex'] as int? ?? 0,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime'] as String) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      subtasks: (map['subtasks'] as List? ?? [])
          .map((s) => SubtaskModel.fromMap(Map<String, dynamic>.from(s)))
          .toList(),
      recurrencePattern: map['recurrencePattern'] as String? ?? 'none',
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }
}
