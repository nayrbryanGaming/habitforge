import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/habit_log_model.dart';
import '../authentication/auth_provider.dart';
import 'habit_provider.dart';
import '../../widgets/glass_card.dart';


class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid ?? '';
    final habitStream = ref.watch(habitsStreamProvider(userId));
    final logsAsync = ref.watch(habitLogsProvider(habitId));

    return habitStream.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (habits) {
        final habitIndex = habits.indexWhere((h) => h.habitId == habitId);
        if (habitIndex == -1) return const Scaffold(body: Center(child: Text('Habit not found')));
        
        final habit = habits[habitIndex];
        final habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Stack(
            children: [
              // Background Accents
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 3.seconds, curve: Curves.easeInOut),
              ),

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Liquid Glass AppBar
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      _buildAppBarAction(
                        icon: Icons.edit_outlined,
                        onTap: () => context.push(AppRoutes.editHabit.replaceFirst(':id', habitId)),
                      ),
                      const SizedBox(width: 8),
                      _buildAppBarAction(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        onTap: () => _confirmDelete(context, ref),
                      ),
                      const SizedBox(width: 16),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  habitColor.withValues(alpha: 0.15),
                                  AppColors.backgroundLight,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: habitColor.withValues(alpha: 0.2),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(habit.icon, style: const TextStyle(fontSize: 48)),
                                    ),
                                  ).animate().scale(curve: Curves.easeOutBack),
                                  const SizedBox(height: 16),
                                  Text(
                                    habit.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                                  const SizedBox(height: 4),
                                  Text(
                                    habit.description.isNotEmpty ? habit.description : 'Your path to mastery begins with this first step. Keep the forge lit.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Summary Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'CURRENT STREAK',
                                '${habit.currentStreak}',
                                'UNSTOPPABLE',
                                AppColors.streakFire,
                                Icons.local_fire_department_rounded,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildSummaryCard(
                                'ELITE RECORD',
                                '${habit.longestStreak}',
                                'THE BENCHMARK',
                                AppColors.streakGold,
                                Icons.emoji_events_rounded,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),

                        // Momentum Heatmap
                        _buildSectionHeader('CONSISTENCY GRID', Icons.grid_view_rounded),
                        const SizedBox(height: 16),
                        logsAsync.when(
                          loading: () => _buildGlassContainer(height: 200, child: const Center(child: CircularProgressIndicator())),
                          error: (e, s) => Text('Error: $e'),
                          data: (logs) => _buildHeatmap(habitColor, logs).animate().fadeIn(duration: 600.ms),
                        ),

                        const SizedBox(height: 32),

                        // Performance Trend
                        _buildSectionHeader('PERFORMANCE FLOW', Icons.auto_graph_rounded),
                        const SizedBox(height: 20),
                        logsAsync.when(
                          loading: () => const SizedBox(height: 180),
                          error: (e, s) => const SizedBox(),
                          data: (logs) => _buildTrendChart(habitColor, logs).animate().fadeIn(duration: 800.ms),
                        ),

                        const SizedBox(height: 48),

                        // Philosophical Reinforcement
                        GlassCard(
                          color: habitColor,
                          opacity: 0.05,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.format_quote_rounded, color: habitColor.withValues(alpha: 0.3), size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  '"We are what we repeatedly do. Excellence, then, is not an act, but a habit."',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: habitColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ARISTOTLE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBarAction({required IconData icon, required VoidCallback onTap, Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.premiumShadow,
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? AppColors.textPrimary, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, String subLabel, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value, 
            style: GoogleFonts.outfit(fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: AppColors.textPrimary)
          ),
          const SizedBox(height: 4),
          Text(subLabel, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required double height, required Widget child}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildHeatmap(Color habitColor, List<HabitLogModel> logs) {
    final logMap = {for (final log in logs) DateTime(log.date.year, log.date.month, log.date.day): log.completed};
    final now = DateTime.now();
    final startOfPeriod = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 34));
    final dates = List.generate(35, (i) => startOfPeriod.add(Duration(days: i)));

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1.5),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isCompleted = logMap[DateTime(date.year, date.month, date.day)] ?? false;
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

          return AnimatedContainer(
            duration: 500.ms,
            decoration: BoxDecoration(
              color: isCompleted ? habitColor : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: isToday ? Border.all(color: habitColor, width: 2.5) : null,
              boxShadow: isCompleted 
                  ? [BoxShadow(color: habitColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : null,
            ),
          ).animate(delay: (index * 15).ms).scale(duration: 400.ms, curve: Curves.easeOutBack);
        },
      ),
    );
  }

  Widget _buildTrendChart(Color habitColor, List<HabitLogModel> logs) {
    if (logs.isEmpty) return const SizedBox();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 32, 32, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1.5),
      ),
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
              barWidth: 8,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    habitColor.withValues(alpha: 0.4),
                    habitColor.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 48),
            ),
            const SizedBox(height: 24),
            Text('ABANDON THIS FORGE?', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            const Text(
              'All data, streaks, and architectural history for this habit will be permanently deleted. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('KEEP IT', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(habitNotifierProvider.notifier).deleteHabit(habitId);
                      Navigator.pop(context); // close sheet
                      context.pop(); // go back
                      HapticFeedback.heavyImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text('EXTINGUISH', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
