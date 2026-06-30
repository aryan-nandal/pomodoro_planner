import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';

class TaskChecklist extends StatefulWidget {
  final List<Subtask> subtasks;
  final ValueChanged<String> onToggleSubtask;
  final ValueChanged<Subtask> onAddSubtask;
  final ValueChanged<String> onDeleteSubtask;

  const TaskChecklist({
    super.key,
    required this.subtasks,
    required this.onToggleSubtask,
    required this.onAddSubtask,
    required this.onDeleteSubtask,
  });

  @override
  State<TaskChecklist> createState() => _TaskChecklistState();
}

class _TaskChecklistState extends State<TaskChecklist> {
  final TextEditingController _controller = TextEditingController();

  void _submitSubtask() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      final sub = Subtask(
        id: const Uuid().v4(),
        title: title,
        isCompleted: false,
      );
      widget.onAddSubtask(sub);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Checklist',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (widget.subtasks.isNotEmpty)
              Text(
                '${widget.subtasks.where((s) => s.isCompleted).length}/${widget.subtasks.length} Done',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Subtask List
        if (widget.subtasks.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.subtasks.length,
            itemBuilder: (context, index) {
              final sub = widget.subtasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.dividerColor, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    dense: true,
                    leading: Checkbox(
                      value: sub.isCompleted,
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (_) => widget.onToggleSubtask(sub.id),
                    ),
                    title: Text(
                      sub.title,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                        color: sub.isCompleted
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => widget.onDeleteSubtask(sub.id),
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 4),
        // Subtask input field
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add an item...',
                    hintStyle: TextStyle(color: theme.colorScheme.secondary, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.dividerColor, width: 0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (_) => _submitSubtask(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              width: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitSubtask,
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
