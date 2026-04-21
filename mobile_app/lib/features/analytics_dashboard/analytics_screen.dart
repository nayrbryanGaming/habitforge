import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/analytics_service.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/skeleton_container.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/analytics_model.dart';
import '../authentication/auth_provider.dart';
import '../habit_management/habit_provider.dart';
import 'analytics_provider.dart';
import 'forge_settings_provider.dart';

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
        title: const Text('FORGE ANALYTICS'),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing analytics coming soon!')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mastery Progress Card
                _buildModernMasteryCard(context, data),
                const SizedBox(height: 32),

                // Core Stats Grid
                _buildSectionHeader('CORE METRICS', Icons.auto_awesome_mosaic_rounded),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildMetricCard('STREAKS', '${data.activeStreaks}', Icons.bolt_rounded, AppColors.accent),
                    _buildMetricCard('TOTAL', '${data.totalCompletions}', Icons.check_circle_rounded, AppColors.success),
                    _buildMetricCard('HABITS', '${data.totalHabits}', Icons.layers_rounded, AppColors.primary),
                    _buildMetricCard('RECORD', '${data.longestStreak}d', Icons.emoji_events_rounded, AppColors.gold),
                  ],
                ),
                const SizedBox(height: 40),

                // AI INSIGHTS
                _buildSectionHeader('FORGE MASTER INSIGHTS', Icons.psychology_rounded),
                const SizedBox(height: 16),
                _buildIntensitySelector(ref),
                const SizedBox(height: 16),
                _buildInsightCard(data),
                const SizedBox(height: 32),

                // TREND
                _buildSectionHeader('WEEKLY PERFORMANCE', Icons.insights_rounded),
                const SizedBox(height: 16),
                _buildWeeklyChart(data).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),

                // PERFORMANCE LIST
                _buildSectionHeader('HABIT EFFICIENCY', Icons.auto_graph_rounded),
                const SizedBox(height: 16),
                _buildHabitList(ref, userId, data),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernMasteryCard(BuildContext context, AnalyticsModel data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.forgeGradient,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.premiumShadow,
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
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(data.weeklyCompletionRate * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: 1.seconds,
                curve: Curves.easeOutExpo,
                height: 12,
                width: (MediaQuery.of(context).size.width - 104) * data.weeklyCompletionRate,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ).animate().shimmer(duration: 2.seconds),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AnalyticsModel data) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.backgroundDark,
              tooltipRoundedRadius: 8,
            ),
          ),
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
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      day,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                    ),
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
                  gradient: AppColors.primaryGradient,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1,
                    color: AppColors.backgroundLight,
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
        if (habits.isEmpty) return const SizedBox();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final habit = habits[index];
            final rate = data.habitCompletionRates[habit.habitId] ?? 0.0;
            final color = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(habit.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          habit.title,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                        ),
                      ),
                      Text(
                        '${(rate * 100).toInt()}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: 800.ms,
                        height: 6,
                        width: (MediaQuery.of(context).size.width - 80) * rate,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.1);
          },
        );
      },
    );
  }

  Widget _buildInsightCard(AnalyticsModel data) {
    final insight = AnalyticsService.getForgeInsight(data);
    return Container(
      padding: const EdgeInsets.all(28),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 32),
          const SizedBox(height: 16),
          Text(
            insight,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildIntensitySelector(WidgetRef ref) {
    final currentIntensity = ref.watch(forgeSettingsProvider).intensity;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: ['Mindful', 'Balanced', 'Aggressive'].map((level) {
          final isSelected = currentIntensity == level;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(forgeSettingsProvider.notifier).setIntensity(level);
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    level.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
