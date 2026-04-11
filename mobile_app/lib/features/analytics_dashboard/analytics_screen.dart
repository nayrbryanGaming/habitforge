import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../authentication/auth_provider.dart';
import 'analytics_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCards(context, data),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Icon(Icons.show_chart, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text('Forging Consistency', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      _buildWeeklyChart(data).animate().fadeIn(delay: 200.ms).scale(),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Icon(Icons.military_tech, color: AppColors.streakGold),
                          const SizedBox(width: 12),
                          Text('Habit Performance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideX(),
                      const SizedBox(height: 16),
                      _buildHabitList(data),
                    ],
                  ),
                ),
              ),
            ],
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
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(context, 'Success Rate', '${(data.weeklyCompletionRate * 100).toInt()}%', Icons.auto_graph, AppColors.success, 0),
        _buildStatCard(context, 'Active Fire', '${data.activeStreaks}', Icons.local_fire_department, AppColors.streakFire, 1),
        _buildStatCard(context, 'Forged Habits', '${data.totalHabits}', Icons.inventory_2, AppColors.primary, 2),
        _buildStatCard(context, 'Elite Streak', '${data.longestStreak} d', Icons.workspace_premium, AppColors.streakGold, 3),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
  }

  Widget _buildWeeklyChart(dynamic data) {
    if (data.weeklyData.isEmpty) return const SizedBox();

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Completion Trends', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${(rod.toY * 100).toInt()}%',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final index = value.toInt();
                        if (index < 0 || index >= data.weeklyData.length) return const Text('');
                        final date = data.weeklyData[index].date;
                        final dayStr = days[date.weekday - 1];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(dayStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: BorderRadius.circular(6),
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
        ],
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
        // In a real app, you'd fetch the habit title/icon from a provider
        // For this UI demo, we'll use generic styling
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.bolt, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Habit ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '${(entry.value * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: entry.value,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
            ],
          ),
        ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.1);
      },
    );
  }
}
