import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_planner/features/auth/presentation/screens/user_profile_drawer.dart';
import 'package:pomodoro_planner/features/pomodoro/presentation/screens/pomodoro_screen.dart';
import 'package:pomodoro_planner/features/statistics/presentation/screens/stats_screen.dart';
import '../../../pomodoro/presentation/bloc/index.dart';
import 'task_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TaskPlannerScreen(
        onFocusTask: (task) {
          // Select task and automatically route user to Pomodoro tab and start focus
          final pomodoroBloc = context.read<PomodoroBloc>();
          pomodoroBloc.add(SelectFocusTask(task));
          pomodoroBloc.add(StartTimer());
          setState(() {
            _currentIndex = 1; // Index of Pomodoro Screen
          });
        },
      ),
      const PomodoroScreen(),
      const StatsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      endDrawer: const UserProfileDrawer(),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 22,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
