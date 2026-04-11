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
    final habitStream = ref.watch(habitsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Forge Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => context.push(AppRoutes.editHabit.replaceFirst(':id', habitId)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: habitStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          final habit = habits.firstWhere((h) => h.habitId == habitId);
          final habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: habitColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(habit.icon, style: const TextStyle(fontSize: 50)),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.backOut),
                      const SizedBox(height: 16),
                      Text(
                        habit.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'FORGING FOR ${habit.currentStreak} DAYS',
                        style: TextStyle(
                          color: AppColors.primary,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text('Performance Stats', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Current Streak',
                        value: '${habit.currentStreak}',
                        icon: Icons.local_fire_department,
                        color: AppColors.streakFire,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: 'Best Streak',
                        value: '${habit.longestStreak}',
                        icon: Icons.emoji_events,
                        color: AppColors.streakGold,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideX(),
                const SizedBox(height: 32),
                Text('Consistency Heatmap', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildHeatmap(habitColor).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 48),
                const Center(
                  child: Text(
                    'Keep forging. Your future self will thank you.',
                    style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeatmap(Color habitColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 28, // Last 4 weeks
        itemBuilder: (context, index) {
          // Dynamic simulation of some completed days
          final isCompleted = index % 3 != 0;
          return Container(
            decoration: BoxDecoration(
              color: isCompleted ? habitColor.withOpacity(0.8) : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Destroy this Habit?'),
        content: const Text('All streaks and progress will be lost forever.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(habitNotifierProvider.notifier).deleteHabit(habitId);
              context.pop();
            },
            child: const Text('Destroy', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
