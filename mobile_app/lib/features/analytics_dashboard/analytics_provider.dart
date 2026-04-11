import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/habit_service.dart';
import '../../models/analytics_model.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';

final analyticsProvider =
    FutureProvider.family<AnalyticsModel, String>((ref, userId) async {
  final habitService = HabitService();

  // Get all active habits
  final habitsSnap = await habitService.getUserHabits(userId).first;
  final weeklyLogs = await habitService.getWeeklyLogs(userId);
  final monthlyLogs = await habitService.getMonthlyLogs(userId);

  // Build daily completion data for last 7 days
  final weeklyData = _buildDailyData(habitsSnap, weeklyLogs, 7);
  final monthlyData = _buildDailyData(habitsSnap, monthlyLogs, 30);

  // Compute completion rates
  final weeklyRate = _computeRate(weeklyData);
  final monthlyRate = _computeRate(monthlyData);

  // Active streaks
  final activeStreaks = habitsSnap.where((h) => h.currentStreak > 0).length;
  final longestStreak = habitsSnap.fold<int>(
      0, (max, h) => h.longestStreak > max ? h.longestStreak : max);

  // Per-habit rates
  final habitRates = <String, double>{};
  for (final habit in habitsSnap) {
    final habitLogs =
        monthlyLogs.where((l) => l.habitId == habit.habitId).toList();
    final completedCount = habitLogs.where((l) => l.completed).length;
    habitRates[habit.habitId] =
        habitLogs.isEmpty ? 0 : completedCount / habitLogs.length;
  }

  return AnalyticsModel(
    userId: userId,
    totalHabits: habitsSnap.length,
    activeStreaks: activeStreaks,
    weeklyCompletionRate: weeklyRate,
    monthlyCompletionRate: monthlyRate,
    longestStreak: longestStreak,
    totalCompletions: monthlyLogs.where((l) => l.completed).length,
    habitCompletionRates: habitRates,
    weeklyData: weeklyData,
    monthlyData: monthlyData,
  );
});

List<DailyCompletion> _buildDailyData(
  List<HabitModel> habits,
  List<HabitLogModel> logs,
  int days,
) {
  final result = <DailyCompletion>[];
  final now = DateTime.now();

  for (int i = days - 1; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dayStart = DateTime(date.year, date.month, date.day);

    final dayLogs = logs.where((l) {
      final logDate = DateTime(l.date.year, l.date.month, l.date.day);
      return logDate == dayStart;
    }).toList();

    // Count habits scheduled for this day
    final scheduledHabits = habits.where((h) {
      if (h.isDaily) return true;
      return h.scheduleDays.contains(date.weekday);
    }).length;

    final completedCount = dayLogs.where((l) => l.completed).length;

    result.add(DailyCompletion(
      date: dayStart,
      total: scheduledHabits,
      completed: completedCount,
    ));
  }

  return result;
}

double _computeRate(List<DailyCompletion> data) {
  if (data.isEmpty) return 0;
  final totalScheduled = data.fold<int>(0, (sum, d) => sum + d.total);
  if (totalScheduled == 0) return 0;
  final totalCompleted = data.fold<int>(0, (sum, d) => sum + d.completed);
  return totalCompleted / totalScheduled;
}
