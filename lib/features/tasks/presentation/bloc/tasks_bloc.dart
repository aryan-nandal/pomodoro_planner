import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../domain/repositories/tasks_repository.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksRepository _repository;
  final AudioService _audioService;
  final HapticService _hapticService;

  TasksBloc({
    required TasksRepository repository,
    required AudioService audioService,
    required HapticService hapticService,
  }) : _repository = repository,
       _audioService = audioService,
       _hapticService = hapticService,
       super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleSubtask>(_onToggleSubtask);
    on<SearchTasksEvent>(_onSearchTasks);
    on<LoadArchive>(_onLoadArchive);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await _repository.getTasks(event.date);
      emit(TasksLoaded(tasks: tasks, selectedDate: event.date));
    } catch (e) {
      emit(TasksError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      await _repository.saveTask(event.task);
      add(LoadTasks(event.task.scheduledDate));
    } catch (e) {
      if (state is TasksLoaded) {
        emit((state as TasksLoaded).copyWith(error: 'Failed to add task'));
      }
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    final currentState = state;
    try {
      if (currentState is TasksLoaded) {
        // Find existing task to check if we just completed it
        final existingTaskIndex = currentState.tasks.indexWhere(
          (t) => t.id == event.task.id,
        );
        if (existingTaskIndex != -1) {
          final existingTask = currentState.tasks[existingTaskIndex];
          if (!existingTask.isCompleted && event.task.isCompleted) {
            // Play success chime & haptic feedback on completion
            _audioService.playSuccessChime();
            _hapticService.successFeedback();
          }
        }
      }

      await _repository.saveTask(event.task);
      add(LoadTasks(event.task.scheduledDate));
    } catch (e) {
      if (currentState is TasksLoaded) {
        emit(currentState.copyWith(error: 'Failed to update task'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await _repository.deleteTask(event.id);
      add(LoadTasks(event.date));
    } catch (e) {
      if (state is TasksLoaded) {
        emit((state as TasksLoaded).copyWith(error: 'Failed to delete task'));
      }
    }
  }

  Future<void> _onToggleSubtask(
    ToggleSubtask event,
    Emitter<TasksState> emit,
  ) async {
    final currentState = state;
    if (currentState is TasksLoaded) {
      try {
        final taskIndex = currentState.tasks.indexWhere(
          (t) => t.id == event.taskId,
        );
        if (taskIndex != -1) {
          final task = currentState.tasks[taskIndex];
          final updatedSubtasks = task.subtasks.map((sub) {
            if (sub.id == event.subtaskId) {
              final newCompletion = !sub.isCompleted;
              if (newCompletion) {
                _audioService.playSuccessChime();
                _hapticService.lightImpact();
              }
              return sub.copyWith(isCompleted: newCompletion);
            }
            return sub;
          }).toList();

          // Check if all subtasks are now completed, then auto-complete task
          final allSubtasksCompleted =
              updatedSubtasks.isNotEmpty &&
              updatedSubtasks.every((sub) => sub.isCompleted);

          final updatedTask = task.copyWith(
            subtasks: updatedSubtasks,
            isCompleted: allSubtasksCompleted ? true : task.isCompleted,
            completedAt: allSubtasksCompleted
                ? DateTime.now()
                : task.completedAt,
          );

          if (allSubtasksCompleted && !task.isCompleted) {
            _audioService.playSuccessChime();
            _hapticService.successFeedback();
          }

          await _repository.saveTask(updatedTask);
          add(LoadTasks(event.date));
        }
      } catch (e) {
        emit(currentState.copyWith(error: 'Failed to toggle subtask'));
      }
    }
  }

  Future<void> _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    final currentState = state;
    if (currentState is TasksLoaded) {
      emit(TasksLoading());
      try {
        final results = await _repository.searchTasks(event.query);
        emit(currentState.copyWith(searchResults: results));
      } catch (e) {
        emit(currentState.copyWith(error: 'Search failed'));
      }
    }
  }

  Future<void> _onLoadArchive(
    LoadArchive event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    try {
      final archive = await _repository.getArchivedTasks();
      emit(
        TasksLoaded(
          tasks: const [],
          selectedDate: DateTime.now(),
          archivedTasks: archive,
        ),
      );
    } catch (e) {
      emit(TasksError('Failed to load archive: ${e.toString()}'));
    }
  }
}
