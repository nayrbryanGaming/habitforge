class AnalyticsModel {
  final String userId;
  final int totalHabits;
  final int activeStreaks;
  final double weeklyCompletionRate;
  final double monthlyCompletionRate;
  final int longestStreak;
  final int totalCompletions;
  final Map<String, double> habitCompletionRates;
  final String forgeIntensity; // 'Mindful', 'Balanced', 'Aggressive'
  final List<DailyCompletion> weeklyData;
  final List<DailyCompletion> monthlyData;

  const AnalyticsModel({
    required this.userId,
    required this.totalHabits,
    required this.activeStreaks,
    required this.weeklyCompletionRate,
    required this.monthlyCompletionRate,
    required this.longestStreak,
    required this.totalCompletions,
    required this.habitCompletionRates,
    required this.forgeIntensity,
    required this.weeklyData,
    required this.monthlyData,
  });
}

class DailyCompletion {
  final DateTime date;
  final int total;
  final int completed;

  const DailyCompletion({
    required this.date,
    required this.total,
    required this.completed,
  });

  double get rate => total == 0 ? 0 : completed / total;
}
