import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/skeleton_container.dart';
import '../authentication/auth_provider.dart';
import 'analytics_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/empty_state_widget.dart';
import '../../core/services/analytics_service.dart';
import '../../core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid ?? '';
    
    if (userId.isEmpty) return const Center(child: CircularProgressIndicator());

    final analyticsAsync = ref.watch(analyticsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Forge Analytics'),
        centerTitle: true,
      ),
      body: analyticsAsync.when(
        loading: () => const _AnalyticsSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          if (data.totalHabits == 0) {
            return ForgeEmptyState(
              title: 'Mastery Begins with Action',
              subtitle: 'Unlock deep insights into your discipline by forging your first habit today.',
              icon: '📊',
              buttonLabel: 'START YOUR JOURNEY',
              onButtonPressed: () => context.push(AppRoutes.createHabit),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mastery Progress Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WEEKLY MASTERY',
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(data.weeklyCompletionRate * 100).toInt()}%',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: data.weeklyCompletionRate,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),

                // Core Stats Grid
                _buildSectionHeader('CORE METRICS', Icons.analytics_rounded),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard('ACTIVE STREAKS', '${data.activeStreaks}', Icons.local_fire_department, AppColors.streakFire),
                    _buildMetricCard('TOTAL FORGED', '${data.totalCompletions}', Icons.check_circle, AppColors.success),
                    _buildMetricCard('HABITS', '${data.totalHabits}', Icons.inventory_2, AppColors.primary),
                    _buildMetricCard('RECORD', '${data.longestStreak}d', Icons.emoji_events, AppColors.streakGold),
                  ],
                ),
                const SizedBox(height: 40),

                // FORGE AI INSIGHTS
                _buildSectionHeader('CHIEF ARCHITECT INSIGHTS', Icons.auto_awesome_rounded),
                const SizedBox(height: 16),
                _buildInsightCard(data),
                const SizedBox(height: 32),

                // MASTERY BADGES
                _buildSectionHeader('MASTERY BADGES', Icons.workspace_premium_rounded),
                const SizedBox(height: 16),
                _buildBadgesGrid(data),
                const SizedBox(height: 40),

                // Completion Trend
                _buildSectionHeader('COMPLETION TREND', Icons.show_chart_rounded),
                const SizedBox(height: 16),
                _buildWeeklyChart(data).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),

                // Individual Habit Performance
                _buildSectionHeader('HABIT PERFORMANCE', Icons.list_alt_rounded),
                const SizedBox(height: 16),
                _buildHabitList(ref, userId, data),
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
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AnalyticsModel data) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final index = val.toInt();
                  if (index < 0 || index >= data.weeklyData.length) return const SizedBox();
                  final day = days[data.weeklyData[index].date.weekday - 1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(day, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
          barGroups: List.generate(data.weeklyData.length, (i) {
            final day = data.weeklyData[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: day.rate,
                  color: AppColors.primary,
                  width: 12,
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
    );
  }

  Widget _buildHabitList(WidgetRef ref, String userId, AnalyticsModel data) {
    final habitsAsync = ref.watch(habitsStreamProvider(userId));

    return habitsAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (habits) {
        if (habits.isEmpty) return const Center(child: Text('No habits yet.'));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final habit = habits[index];
            final rate = data.habitCompletionRates[habit.habitId] ?? 0.0;
            final color = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(habit.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Text(
                        '${(rate * 100).toInt()}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 6,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
          },
        );
      },
    );
  }

  Widget _buildInsightCard(AnalyticsModel data) {
    final insight = AnalyticsService.getForgeInsight(data);
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SENSEI ARCHITECT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }

  Widget _buildBadgesGrid(AnalyticsModel data) {
    final badges = AnalyticsService.calculateMasteryBadges(data);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: badges.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('No badges earned yet. Forge ahead!', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: badges.length,
              itemBuilder: (context, i) {
                final badge = badges[i];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(badge['icon'] as String, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ).animate().scale(delay: (i * 100).ms, duration: 400.ms, curve: Curves.backOut);
              },
            ),
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SkeletonContainer(width: double.infinity, height: 160, borderRadius: BorderRadius.all(Radius.circular(32))),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: List.generate(4, (index) => const SkeletonContainer.rounded(width: double.infinity, height: 80)),
          ),
          const SizedBox(height: 32),
          const SkeletonContainer(width: double.infinity, height: 220, borderRadius: BorderRadius.all(Radius.circular(24))),
          const SizedBox(height: 32),
          const SkeletonContainer(width: double.infinity, height: 300, borderRadius: BorderRadius.all(Radius.circular(24))),
        ],
      ),
    );
  }
}
