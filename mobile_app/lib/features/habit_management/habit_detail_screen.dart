import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import 'habit_provider.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid ?? '';
    final habitStream = ref.watch(habitsStreamProvider(userId));
    final logsAsync = ref.watch(habitLogsProvider(habitId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Forge Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editHabit.replaceFirst(':id', habitId)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: habitStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          final habit = habits.firstWhere((h) => h.habitId == habitId);
          final habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: habitColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: habitColor.withOpacity(0.2), width: 6),
                        ),
                        child: Center(
                          child: Text(habit.icon, style: const TextStyle(fontSize: 56)),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.backOut),
                      const SizedBox(height: 20),
                      Text(
                        habit.title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          habit.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Streak Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'CURRENT',
                        '${habit.currentStreak}',
                        'Days Streak',
                        AppColors.streakFire,
                        Icons.local_fire_department_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'BEST',
                        '${habit.longestStreak}',
                        'Record Streak',
                        AppColors.streakGold,
                        Icons.emoji_events_rounded,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),

                // Heatmap & Charts
                _buildSectionHeader('CONSISTENCY HEATMAP', Icons.grid_view_rounded),
                const SizedBox(height: 16),
                logsAsync.when(
                  loading: () => Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                  error: (e, s) => Text('Error loading logs: $e'),
                  data: (logs) => _buildHeatmap(habitColor, logs).animate().fadeIn(delay: 600.ms),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader('PERFORMANCE TREND', Icons.show_chart_rounded),
                const SizedBox(height: 20),
                logsAsync.when(
                  loading: () => const SizedBox(height: 150),
                  error: (e, s) => const SizedBox(),
                  data: (logs) => _buildTrendChart(habitColor, logs).animate().fadeIn(delay: 800.ms),
                ),
                const SizedBox(height: 48),

                // Motivational Quote
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.format_quote, color: AppColors.primary.withOpacity(0.3), size: 32),
                        const SizedBox(height: 12),
                        const Text(
                          'Successful people are simply those with successful habits.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('- Brian Tracy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, String subLabel, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(subLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildHeatmap(Color habitColor, List<HabitLogModel> logs) {
    final logMap = {for (final log in logs) DateTime(log.date.year, log.date.month, log.date.day): log.completed};
    final now = DateTime.now();
    final dates = List.generate(35, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 34 - i)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isCompleted = logMap[date] ?? false;
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

          return Container(
            decoration: BoxDecoration(
              color: isCompleted ? habitColor : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: isToday ? Border.all(color: habitColor, width: 2) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendChart(Color habitColor, List<HabitLogModel> logs) {
    if (logs.isEmpty) return const SizedBox();

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(logs.length, (i) {
                final log = logs[logs.length - 1 - i];
                return FlSpot(i.toDouble(), log.completed ? 1 : 0);
              }),
              isCurved: true,
              color: habitColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: habitColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Destroy this Habit?'),
        content: const Text('All streaks and progress for this habit will be lost forever.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep it')),
          TextButton(
            onPressed: () {
              ref.read(habitNotifierProvider.notifier).deleteHabit(habitId);
              Navigator.pop(context); // close dialog
              context.pop(); // go back
            },
            child: const Text('Destroy', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
