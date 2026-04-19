import 'package:firebase_analytics/firebase_analytics.dart';
import '../../models/analytics_model.dart';
import '../../models/habit_model.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logHabitCreated(HabitModel habit) async {
    await _analytics.logEvent(
      name: 'habit_created',
      parameters: {
        'id': habit.habitId,
        'title': habit.title,
        'schedule': habit.scheduleType,
      },
    );
  }

  static Future<void> logHabitCompleted(String habitId, String title) async {
    await _analytics.logEvent(
      name: 'habit_completed',
      parameters: {
        'id': habitId,
        'title': title,
      },
    );
  }

  static Future<void> logLevelUp(int streak) async {
    await _analytics.logLevelUp(level: streak);
  }

  static String getForgeInsight(AnalyticsModel data) {
    if (data.totalHabits == 0) return "Forge your first habit to start the mastery journey.";

    final rate = data.weeklyCompletionRate;
    final intensity = data.forgeIntensity.toLowerCase();

    // Mapping of insights based on intensity and rate
    final Map<String, Map<String, String>> responseMatrix = {
      'mindful': {
        'legendary': "Peaceful progress. Your consistency is like a calm river—effortless and powerful. Maintain this flow.",
        'strong': "You are finding your rhythm. Focus on the breath between tasks to solidify this foundation.",
        'foundation': "Be kind to your progress. You're building the base. Every small entry is a victory for the soul.",
        'cycle': "Observation without judgment. Notice the gaps and gently return to your practice today.",
        'cold': "The forge is resting. Gently light a small spark today when you are ready."
      },
      'balanced': {
        'legendary': "LEGENDARY consistency. Your architect's vision is becoming reality. Keep this momentum!",
        'strong': "Strong progress! You're forging a solid middle-ground. Focusing on morning habits might push you to 90%.",
        'foundation': "You're building the foundation. The key is to never skip two days in a row. Forge ahead!",
        'cycle': "Resistance is natural. Start with small, microscopic wins today to break the cycle.",
        'cold': "The forge is cold. Light the match today with one small task."
      },
      'aggressive': {
        'legendary': "ABSOLUTE DOMINANCE. You are outperforming 99% of forgers. Do not let up. Push harder.",
        'strong': "GOOD, but not great. That 30% gap is where weakness hides. Close it today.",
        'foundation': "MEDIOCRE. Foundations are for building, not staying. Increase the heat immediately.",
        'cycle': "EXCUSES. The cycle is a cage. Break it with raw discipline right now.",
        'cold': "PATHETIC. The forge is dead. Reboot your discipline or accept defeat."
      }
    };

    final level = intensity == 'mindful' ? 'mindful' : (intensity == 'aggressive' ? 'aggressive' : 'balanced');
    String feedbackKey;
    if (rate >= 0.9) feedbackKey = 'legendary';
    else if (rate >= 0.7) feedbackKey = 'strong';
    else if (rate >= 0.4) feedbackKey = 'foundation';
    else if (rate > 0) feedbackKey = 'cycle';
    else feedbackKey = 'cold';

    return responseMatrix[level]![feedbackKey]!;
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
