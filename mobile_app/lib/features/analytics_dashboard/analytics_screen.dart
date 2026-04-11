import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../authentication/auth_provider.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    final analyticsAsync = ref.watch(analyticsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Progress'),
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, data),
                const SizedBox(height: 32),
                Text('Weekly Consistency', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildWeeklyChart(data),
                const SizedBox(height: 32),
                Text('Habit Performance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildHabitList(data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, dynamic data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, 'Completion Rate', '${(data.weeklyCompletionRate * 100).toInt()}%', Icons.analytics),
        _buildStatCard(context, 'Active Streaks', '${data.activeStreaks}', Icons.local_fire_department, AppColors.streakFire),
        _buildStatCard(context, 'Total Habits', '${data.totalHabits}', Icons.format_list_bulleted),
        _buildStatCard(context, 'Longest Streak', '${data.longestStreak} d', Icons.emoji_events, AppColors.streakGold),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, [Color color = AppColors.primary]) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(dynamic data) {
    if (data.weeklyData.isEmpty) return const SizedBox();

    return SizedBox(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.0,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      final index = value.toInt();
                      if (index < 0 || index >= data.weeklyData.length) return const Text('');
                      // Get correct day of week for the data point
                      final date = data.weeklyData[index].date;
                      final dayStr = days[date.weekday - 1];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(dayStr, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(data.weeklyData.length, (index) {
                final dayData = data.weeklyData[index];
                final val = dayData.total == 0 ? 0.0 : (dayData.completed / dayData.total);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: AppColors.primary,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 1,
                        color: AppColors.surfaceLight,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitList(dynamic data) {
    if (data.habitCompletionRates.isEmpty) {
      return const Center(child: Text('No habit data yet.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.habitCompletionRates.length,
      itemBuilder: (context, index) {
        final entry = data.habitCompletionRates.entries.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Habit ID: ${entry.key.substring(0, 5)}...'),
                  Text('${(entry.value * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: entry.value,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ],
          ),
        );
      },
    );
  }
}
