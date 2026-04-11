import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../authentication/auth_provider.dart';
import 'habit_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildDailyQuote(context).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Forging Progress',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completedCount of ${habits.length} habits forged',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.backOut),
              ),
              if (habits.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderListener(
                      (context, index) {
                        final item = habits[index];
                        final habitColor = Color(int.parse(item.habit.color.replaceFirst('#', '0xFF')));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: item.completed ? AppColors.success.withOpacity(0.2) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          elevation: 0,
                          color: item.completed ? Colors.white : Colors.white.withOpacity(0.9),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => context.push('/habit/${item.habit.habitId}'),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: item.completed ? AppColors.success.withOpacity(0.1) : habitColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.habit.icon,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ).animate(target: item.completed ? 1 : 0).scale(duration: 300.ms, curve: Curves.backOut),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.habit.title,
                                          style: TextStyle(
                                            decoration: item.completed ? TextDecoration.lineThrough : null,
                                            color: item.completed ? AppColors.textSecondary : AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        item.habit.currentStreak > 0
                                            ? Row(
                                                children: [
                                                  const Icon(Icons.local_fire_department, size: 14, color: AppColors.streakFire),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${item.habit.currentStreak} DAY STREAK',
                                                    style: const TextStyle(
                                                      color: AppColors.streakFire,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                'FORGE TODAY',
                                                style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 1.3,
                                    child: Checkbox(
                                      value: item.completed,
                                      activeColor: AppColors.success,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate(key: ValueKey('${item.habit.habitId}_${item.completed}'))
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.05)
                        .then(delay: 100.ms)
                        .shake(duration: item.completed ? 400.ms : 0.ms, hz: 4);
                      },
                      childCount: habits.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyQuote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            '"The secret of your future is hidden in your daily routine."',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            '— Mike Murdock',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Helper to use SliverList with index (alternative to ListView.builder in CustomScrollView)
class SliverChildBuilderListener extends SliverChildBuilderDelegate {
  SliverChildBuilderListener(Widget Function(BuildContext, int) builder, {int? childCount})
      : super(builder, childCount: childCount);
}
