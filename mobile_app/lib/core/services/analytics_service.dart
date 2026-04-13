import '../../models/analytics_model.dart';
import '../../models/habit_model.dart';

class AnalyticsService {
  static String getForgeInsight(AnalyticsModel data) {
    if (data.totalHabits == 0) return "Forge your first habit to start the mastery journey.";
    
    if (data.weeklyCompletionRate >= 0.9) {
      return "LEGENDARY consistency. Your architect's vision is becoming reality. Keep this momentum!";
    } else if (data.weeklyCompletionRate >= 0.7) {
      return "Strong progress! You're forging a solid middle-ground. Focusing on morning habits might push you to 90%.";
    } else if (data.weeklyCompletionRate >= 0.4) {
      return "You're building the foundation. The key is to never skip two days in a row. Forge ahead!";
    } else if (data.weeklyCompletionRate > 0) {
      return "Resistance is natural. Start with small, microscopic wins today to break the cycle.";
    } else {
      return "The forge is cold. Light the match today with one small task.";
    }
  }

  static List<Map<String, dynamic>> calculateMasteryBadges(AnalyticsModel data) {
    final List<Map<String, dynamic>> badges = [];
    
    // Streak Badges
    if (data.activeStreaks > 0) badges.add({'id': 'spark', 'name': 'The Spark', 'icon': '🔥', 'description': 'Started a streak'});
    if (data.longestStreak >= 7) badges.add({'id': 'consistent', 'name': '7-Day Architect', 'icon': '📐', 'description': 'Maintained a 7-day streak'});
    if (data.longestStreak >= 30) badges.add({'id': 'master', 'name': 'Master Forger', 'icon': '🔨', 'description': 'Unbreakable 30-day streak'});

    // Completion Badges
    if (data.totalCompletions >= 10) badges.add({'id': 'apprentice', 'name': 'Apprentice', 'icon': '📜', 'description': '10 habits forged'});
    if (data.totalCompletions >= 100) badges.add({'id': 'veteran', 'name': 'Habit Veteran', 'icon': '🛡️', 'description': '100 total completions'});
    
    // Variety Badges
    if (data.totalHabits >= 5) badges.add({'id': 'multitasker', 'name': 'Morning General', 'icon': '🎖️', 'description': 'Managing 5+ habits'});

    return badges;
  }
}
