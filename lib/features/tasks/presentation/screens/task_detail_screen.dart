import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../widgets/category_selector.dart';
import '../widgets/task_checklist.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  final DateTime initialDate;

  const TaskDetailScreen({
    super.key,
    this.task,
    required this.initialDate,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late TaskPriority _priority;
  Category? _category;
  late DateTime _scheduledDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late List<Subtask> _subtasks;
  late String _recurrencePattern;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? TaskPriority.low;
    _category = t?.category;
    _scheduledDate = t?.scheduledDate ?? widget.initialDate;

    if (t?.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(t!.startTime!);
    }
    if (t?.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(t!.endTime!);
    }

    _subtasks = t?.subtasks != null ? List.from(t!.subtasks) : [];
    _recurrencePattern = t?.recurrencePattern ?? 'none';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Theme.of(context).cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      DateTime? startDateTime;
      DateTime? endDateTime;

      if (_startTime != null) {
        startDateTime = DateTime(
          _scheduledDate.year,
          _scheduledDate.month,
          _scheduledDate.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }
      if (_endTime != null) {
        endDateTime = DateTime(
          _scheduledDate.year,
          _scheduledDate.month,
          _scheduledDate.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      final savedTask = Task(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        priority: _priority,
        startTime: startDateTime,
        endTime: endDateTime,
        isCompleted: widget.task?.isCompleted ?? false,
        subtasks: _subtasks,
        recurrencePattern: _recurrencePattern,
        scheduledDate: _scheduledDate,
        completedAt: widget.task?.completedAt,
      );

      Navigator.pop(context, savedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  style: theme.textTheme.titleLarge,
                  decoration: const InputDecoration(
                    hintText: 'Task Title',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Description (optional)',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),

                // Priority Selection
                const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = _priority == p;
                    Color color;
                    String label;
                    switch (p) {
                      case TaskPriority.low:
                        color = theme.colorScheme.secondary;
                        label = 'Low';
                        break;
                      case TaskPriority.medium:
                        color = Colors.amber;
                        label = 'Medium';
                        break;
                      case TaskPriority.high:
                        color = Colors.redAccent;
                        label = 'High';
                        break;
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.white : Colors.transparent,
                            foregroundColor: isSelected ? Colors.black : Colors.white,
                            side: BorderSide(
                              color: isSelected ? Colors.white : theme.dividerColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => setState(() => _priority = p),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.black : color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Category Selection
                CategorySelector(
                  selectedCategory: _category,
                  onCategorySelected: (cat) => setState(() => _category = cat),
                ),
                const SizedBox(height: 24),

                // Schedule Details (Date & Time Blocking)
                const Text('Schedule & Time Blocking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Date Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: ListTile(
                          onTap: _selectDate,
                          dense: true,
                          title: const Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          trailing: const Icon(Icons.calendar_today_outlined, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Start Time
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: ListTile(
                          onTap: () => _selectTime(true),
                          dense: true,
                          title: const Text('Start Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            _startTime?.format(context) ?? 'None',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          trailing: const Icon(Icons.access_time_outlined, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // End Time
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: ListTile(
                          onTap: () => _selectTime(false),
                          dense: true,
                          title: const Text('End Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            _endTime?.format(context) ?? 'None',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          trailing: const Icon(Icons.access_time_outlined, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recurrence
                const Text('Recurrence', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrencePattern,
                  dropdownColor: theme.cardColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('No Repeat')),
                    DropdownMenuItem(value: 'daily', child: Text('Repeat Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Repeat Weekly')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _recurrencePattern = val);
                    }
                  },
                ),
                const SizedBox(height: 28),

                // Subtasks / Checklist
                TaskChecklist(
                  subtasks: _subtasks,
                  onToggleSubtask: (subId) {
                    setState(() {
                      final i = _subtasks.indexWhere((s) => s.id == subId);
                      if (i != -1) {
                        _subtasks[i] = _subtasks[i].copyWith(isCompleted: !_subtasks[i].isCompleted);
                      }
                    });
                  },
                  onAddSubtask: (newSub) {
                    setState(() {
                      _subtasks.add(newSub);
                    });
                  },
                  onDeleteSubtask: (subId) {
                    setState(() {
                      _subtasks.removeWhere((s) => s.id == subId);
                    });
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
