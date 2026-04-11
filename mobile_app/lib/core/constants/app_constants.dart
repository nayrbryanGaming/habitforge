class AppConstants {
  AppConstants._();

  static const String appName = 'HabitForge';
  static const String appTagline = 'Forge powerful habits one day at a time.';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String habitLogsCollection = 'habit_logs';
  static const String analyticsCollection = 'analytics';

  // Shared Preferences Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Habit Limits
  static const int freeHabitLimit = 5;

  // Streak Milestones
  static const List<int> streakMilestones = [3, 7, 14, 21, 30, 60, 90, 180, 365];

  // Analytics
  static const int analyticsWeeklyDays = 7;
  static const int analyticsMonthlyDays = 30;

  // Notification Channel
  static const String notificationChannelId = 'habitforge_reminders';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDesc = 'Daily habit reminder notifications';

  // Default habit colors
  static const List<String> habitColors = [
    '#2563EB',
    '#F97316',
    '#10B981',
    '#8B5CF6',
    '#EF4444',
    '#F59E0B',
    '#06B6D4',
    '#EC4899',
  ];

  // Default habit icons
  static const List<String> habitIcons = [
    '💪', '📚', '🧘', '🏃', '💧', '🥗', '😴', '🎯',
    '💊', '✍️', '🎵', '🌱', '🧹', '💰', '🙏', '🌅',
  ];
}
