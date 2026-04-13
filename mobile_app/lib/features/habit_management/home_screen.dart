import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/skeleton_container.dart';
import '../authentication/auth_provider.dart';
import 'habit_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/empty_state_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    final todayHabits = ref.watch(todayHabitsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HabitForge',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.primary.withOpacity(0.8),
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'Forge your day',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () => context.push(AppRoutes.createHabit),
            ),
          ),
        ],
      ),
      body: todayHabits.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (context, index) => const HabitCardSkeleton(),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          if (habits.isEmpty) {
            return ForgeEmptyState(
              title: 'Forge Your First Habit',
              subtitle: 'Today is a great day to start building consistency. Your future self will thank you.',
              icon: '🏗️',
              buttonLabel: 'START FORGING',
              onButtonPressed: () => context.push(AppRoutes.createHabit),
            );
          }

          int completedCount = habits.where((h) => h.completed).length;
          double progress = habits.isEmpty ? 0 : completedCount / habits.length;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildDailyQuote(context).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark.withOpacity(0.9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: -5,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DAILY MASTERY',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(progress * 100).toInt()}% Complete',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.flash_on, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                height: 12,
                                width: (MediaQuery.of(context).size.width - 80) * progress,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            progress == 1.0 
                              ? 'Legendary! All habits for today are forged. 🔥'
                              : 'Keep going! $completedCount of ${habits.length} habits completed.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
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
                                              HapticFeedback.mediumImpact();
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
              ),
              if (progress == 1.0)
                IgnorePointer(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            color: AppColors.success,
                            size: 72,
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        const Text(
                          'ALL HABITS FORGED! 🔥',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
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
