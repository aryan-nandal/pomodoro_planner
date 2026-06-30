import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/presentation/bloc/tasks_bloc.dart';
import '../../../tasks/presentation/bloc/tasks_state.dart';
import '../bloc/pomodoro_bloc.dart';
import '../bloc/pomodoro_event.dart';
import '../bloc/pomodoro_state.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _getModeLabel(PomodoroType type) {
    switch (type) {
      case PomodoroType.focus:
        return 'FOCUS SESSION';
      case PomodoroType.shortBreak:
        return 'SHORT BREAK';
      case PomodoroType.longBreak:
        return 'LONG BREAK';
    }
  }

  Color _getModeColor(PomodoroType type) {
    switch (type) {
      case PomodoroType.focus:
        return const Color(0xFF6366F1); // Indigo
      case PomodoroType.shortBreak:
        return const Color(0xFF10B981); // Emerald
      case PomodoroType.longBreak:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pomodoro',
                    style: theme.textTheme.displayMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => _showSettingsDialog(context),
                  ),
                ],
              ),
              const Spacer(),

              // Circular Timer Display
              BlocBuilder<PomodoroBloc, PomodoroState>(
                builder: (context, state) {
                  final percent = state.totalSeconds > 0
                      ? state.secondsRemaining / state.totalSeconds
                      : 0.0;
                  final modeColor = _getModeColor(state.type);

                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular track
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 6,
                            color: modeColor,
                            backgroundColor: theme.dividerColor,
                          ),
                        ),
                        // Text contents
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getModeLabel(state.type),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: modeColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDuration(state.secondsRemaining),
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 54,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cycles: ${state.completedCycles}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),

              // Task Selector Section
              BlocBuilder<PomodoroBloc, PomodoroState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: state.selectedTask != null ? Colors.white : theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Focusing On',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.selectedTask?.title ?? 'No Task Selected',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showTaskSelectionDialog(context),
                          child: const Text('Select'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Control Buttons
              BlocBuilder<PomodoroBloc, PomodoroState>(
                builder: (context, state) {
                  final isRunning = state.status == PomodoroStatus.running;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reset button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          context.read<PomodoroBloc>().add(ResetTimer());
                        },
                        child: const Icon(Icons.refresh, size: 24),
                      ),

                      // Play/Pause button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(22),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (isRunning) {
                            context.read<PomodoroBloc>().add(PauseTimer());
                          } else {
                            context.read<PomodoroBloc>().add(StartTimer());
                          }
                        },
                        child: Icon(
                          isRunning ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                      ),

                      // Skip button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          context.read<PomodoroBloc>().add(SkipTimer());
                        },
                        child: const Icon(Icons.skip_next, size: 24),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text('Select Task to Focus On'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: BlocBuilder<TasksBloc, TasksState>(
              builder: (context, taskState) {
                if (taskState is TasksLoaded) {
                  final activeTasks = taskState.tasks.where((t) => !t.isCompleted).toList();
                  if (activeTasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No active tasks planned for today.',
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: activeTasks.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final task = activeTasks[index];
                      return ListTile(
                        dense: true,
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: task.category != null ? Text(task.category!.name) : null,
                        onTap: () {
                          context.read<PomodoroBloc>().add(SelectFocusTask(task));
                          Navigator.pop(dialogCtx);
                        },
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<PomodoroBloc>().add(const SelectFocusTask(null));
                Navigator.pop(dialogCtx);
              },
              child: const Text('Clear Task Selection'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final timerBloc = context.read<PomodoroBloc>();
    final focusCtrl = TextEditingController(text: timerBloc.state.focusDurationMinutes.toString());
    final shortCtrl = TextEditingController(text: timerBloc.state.shortBreakDurationMinutes.toString());
    final longCtrl = TextEditingController(text: timerBloc.state.longBreakDurationMinutes.toString());

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text('Timer Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingField(focusCtrl, 'Focus Session (min)'),
              const SizedBox(height: 12),
              _buildSettingField(shortCtrl, 'Short Break (min)'),
              const SizedBox(height: 12),
              _buildSettingField(longCtrl, 'Long Break (min)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final focus = int.tryParse(focusCtrl.text) ?? 25;
                final short = int.tryParse(shortCtrl.text) ?? 5;
                final long = int.tryParse(longCtrl.text) ?? 15;
                timerBloc.add(SetCustomDurations(
                  focusMinutes: focus,
                  shortBreakMinutes: short,
                  longBreakMinutes: long,
                ));
                Navigator.pop(dialogCtx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
