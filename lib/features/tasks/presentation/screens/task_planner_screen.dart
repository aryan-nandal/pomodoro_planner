import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import 'task_detail_screen.dart';

class TaskPlannerScreen extends StatefulWidget {
  final ValueChanged<Task>? onFocusTask;

  const TaskPlannerScreen({super.key, this.onFocusTask});

  @override
  State<TaskPlannerScreen> createState() => _TaskPlannerScreenState();
}

class _TaskPlannerScreenState extends State<TaskPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    context.read<TasksBloc>().add(LoadTasks(_selectedDate));
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _isSearching = false;
      _searchController.clear();
    });
    _loadTasks();
  }

  IconData _getCategoryIcon(String? name) {
    switch (name) {
      case 'work_outline':
        return Icons.work_outline;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'person_outline':
        return Icons.person_outline;
      case 'repeat':
        return Icons.repeat;
      default:
        return Icons.label_outline;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.blueGrey;
      case TaskPriority.medium:
        return Colors.amber;
      case TaskPriority.high:
        return Colors.redAccent;
    }
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null) return 'All Day';
    final startTime = TimeOfDay.fromDateTime(start).format(context);
    final endTime = end != null
        ? TimeOfDay.fromDateTime(end).format(context)
        : '';
    return endTime.isNotEmpty ? '$startTime - $endTime' : startTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daily Planner', style: theme.textTheme.displayMedium),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _loadTasks();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.archive_outlined),
                        onPressed: () {
                          context.read<TasksBloc>().add(LoadArchive());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle_outlined),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Bar
              if (_isSearching) ...[
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: Icon(Icons.search_outlined, size: 20),
                  ),
                  onChanged: (val) {
                    context.read<TasksBloc>().add(SearchTasksEvent(val));
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Horizontal Calendar Scroller (only if not searching/archive)
              if (!_isSearching) _buildCalendarScroller(),
              const SizedBox(height: 16),

              // Tasks Content
              Expanded(
                child: BlocConsumer<TasksBloc, TasksState>(
                  listener: (context, state) {
                    if (state is TasksLoaded && state.error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error!)));
                    }
                  },
                  builder: (context, state) {
                    if (state is TasksLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (state is TasksLoaded) {
                      final tasksToDisplay =
                          _isSearching && _searchController.text.isNotEmpty
                          ? state.searchResults
                          : (state.archivedTasks.isNotEmpty
                                ? state.archivedTasks
                                : state.tasks);

                      if (tasksToDisplay.isEmpty) {
                        return Center(
                          child: Text(
                            state.archivedTasks.isNotEmpty
                                ? 'No archived tasks found.'
                                : 'No tasks planned for this day.',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        );
                      }

                      return ReorderableListView.builder(
                        itemCount: tasksToDisplay.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final items = List<Task>.from(tasksToDisplay);
                          final item = items.removeAt(oldIndex);
                          items.insert(newIndex, item);

                          // Trigger reorder update (save all to keep ordering)
                          for (int i = 0; i < items.length; i++) {
                            context.read<TasksBloc>().add(UpdateTask(items[i]));
                          }
                        },
                        itemBuilder: (context, index) {
                          final task = tasksToDisplay[index];
                          return _buildTaskCard(
                            task,
                            theme,
                            key: ValueKey(task.id),
                          );
                        },
                      );
                    } else if (state is TasksError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tasksBloc = context.read<TasksBloc>();
          final newTask = await Navigator.push<Task>(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(initialDate: _selectedDate),
            ),
          );
          if (newTask != null) {
            tasksBloc.add(AddTask(newTask));
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildCalendarScroller() {
    final today = DateTime.now();
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // 7 days back, 7 days forward
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - 7));
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final weekDay = _getWeekDayName(date.weekday);
          final dayStr = date.day.toString();

          return GestureDetector(
            onTap: () => _changeDate(date),
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      case 7:
        return 'SUN';
      default:
        return '';
    }
  }

  Widget _buildTaskCard(Task task, ThemeData theme, {required Key key}) {
    final subtasksDone = task.subtasks.where((s) => s.isCompleted).length;
    final totalSubtasks = task.subtasks.length;
    final hasSubtasks = totalSubtasks > 0;

    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        context.read<TasksBloc>().add(DeleteTask(task.id, _selectedDate));
      },
      child: Container(
        key: key,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : theme.dividerColor,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final tasksBloc = context.read<TasksBloc>();
            final updatedTask = await Navigator.push<Task>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TaskDetailScreen(task: task, initialDate: _selectedDate),
              ),
            );
            if (updatedTask != null) {
              tasksBloc.add(UpdateTask(updatedTask));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complete Checkbox
                GestureDetector(
                  onTap: () {
                    context.read<TasksBloc>().add(
                      UpdateTask(
                        task.copyWith(
                          isCompleted: !task.isCompleted,
                          completedAt: !task.isCompleted
                              ? DateTime.now()
                              : null,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isCompleted ? Colors.white : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                          ),
                          // Priority indicator dot
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getPriorityColor(task.priority),
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Meta details row
                      Row(
                        children: [
                          // Time tag
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeRange(task.startTime, task.endTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Category badge
                          if (task.category != null) ...[
                            Icon(
                              _getCategoryIcon(task.category!.iconName),
                              size: 12,
                              color: Color(task.category!.colorHex),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.category!.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(task.category!.colorHex),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          // Checklist count
                          if (hasSubtasks) ...[
                            Icon(
                              Icons.playlist_add_check,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$subtasksDone/$totalSubtasks',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Start focus session button
                if (widget.onFocusTask != null && !task.isCompleted)
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline,
                      size: 26,
                      color: Colors.indigoAccent,
                    ),
                    onPressed: () => widget.onFocusTask!(task),
                    tooltip: 'Start Pomodoro Session',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
