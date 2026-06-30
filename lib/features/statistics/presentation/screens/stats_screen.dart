import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(LoadStats());
  }

  String _getShortDayName(int offsetFromToday) {
    final date = DateTime.now().subtract(Duration(days: 6 - offsetFromToday));
    switch (date.weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Statistics',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 24),

              Expanded(
                child: BlocBuilder<StatsBloc, StatsState>(
                  builder: (context, state) {
                    if (state is StatsLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (state is StatsLoaded) {
                      final taskRate = state.totalTasksToday > 0
                          ? state.completedTasksToday / state.totalTasksToday
                          : 0.0;

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<StatsBloc>().add(LoadStats());
                        },
                        color: Colors.white,
                        backgroundColor: theme.cardTheme.color,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Streak & Overview row
                              Row(
                                children: [
                                  // Streak Card
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      icon: Icons.local_fire_department,
                                      iconColor: Colors.orangeAccent,
                                      title: 'Streak',
                                      value: '${state.dailyStreak} days',
                                      subtitle: 'Keep it going!',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Completed Pomodoros Card
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      icon: Icons.timer_outlined,
                                      iconColor: Colors.indigoAccent,
                                      title: 'Focus Sessions',
                                      value: '${state.totalPomodorosCompleted}',
                                      subtitle: 'Sessions completed',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Focus Time & Completion Rate cards
                              Row(
                                children: [
                                  // Today Focus Minutes
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      icon: Icons.hourglass_empty,
                                      iconColor: Colors.tealAccent,
                                      title: 'Focus Today',
                                      value: '${state.focusMinutesToday} min',
                                      subtitle: 'Total screen time',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Task Rate Card
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      icon: Icons.check_circle_outline,
                                      iconColor: Colors.greenAccent,
                                      title: 'Tasks Today',
                                      value: '${state.completedTasksToday}/${state.totalTasksToday}',
                                      subtitle: '${(taskRate * 100).toInt()}% completed',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Weekly focus duration Bar Chart
                              Text(
                                'Weekly Focus Trend',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _getMaxY(state.focusMinutesLast7Days),
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                _getShortDayName(value.toInt()),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(7, (index) {
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: state.focusMinutesLast7Days[index].toDouble(),
                                            color: Colors.white,
                                            width: 14,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    } else if (state is StatsError) {
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
    );
  }

  double _getMaxY(List<int> values) {
    double max = 60.0; // default minimum max
    for (final val in values) {
      if (val > max) max = val.toDouble();
    }
    return max + 10;
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
