import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../authentication/auth_provider.dart';
import 'habit_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    final todayHabits = ref.watch(todayHabitsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.createHabit),
          ),
        ],
      ),
      body: todayHabits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist_rtl, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No habits for today!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create a new habit.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          int completedCount = habits.where((h) => h.completed).length;
          double progress = habits.isEmpty ? 0 : completedCount / habits.length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedCount of ${habits.length} completed',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final item = habits[index];
                    final habitColor = Color(int.parse(item.habit.color.replaceFirst('#', '0xFF')));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => context.push('/habit/${item.habit.habitId}'),
                        leading: CircleAvatar(
                          backgroundColor: item.completed ? AppColors.successLight : habitColor.withOpacity(0.1),
                          child: Text(
                            item.habit.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          item.habit.title,
                          style: TextStyle(
                            decoration: item.completed ? TextDecoration.lineThrough : null,
                            color: item.completed ? AppColors.textSecondary : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: item.habit.currentStreak > 0
                            ? Row(
                                children: [
                                  const Icon(Icons.local_fire_department, size: 16, color: AppColors.streakFire),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.habit.currentStreak} day streak',
                                    style: const TextStyle(color: AppColors.streakFire, fontSize: 12),
                                  ),
                                ],
                              )
                            : null,
                        trailing: Checkbox(
                          value: item.completed,
                          activeColor: AppColors.success,
                          shape: const CircleBorder(),
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(habitNotifierProvider.notifier).toggleHabitCompletion(
                                    habitId: item.habit.habitId,
                                    userId: user.uid,
                                    date: DateTime.now(),
                                    completed: val,
                                  );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
