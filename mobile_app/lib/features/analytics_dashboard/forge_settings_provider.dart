import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgeSettingsState {
  final String intensity; // 'Mindful', 'Balanced', 'Aggressive'
  final bool dailyDigests;
  final bool streakWarnings;
  final bool achievementAlerts;

  ForgeSettingsState({
    required this.intensity,
    this.dailyDigests = true,
    this.streakWarnings = true,
    this.achievementAlerts = true,
  });

  ForgeSettingsState copyWith({
    String? intensity,
    bool? dailyDigests,
    bool? streakWarnings,
    bool? achievementAlerts,
  }) {
    return ForgeSettingsState(
      intensity: intensity ?? this.intensity,
      dailyDigests: dailyDigests ?? this.dailyDigests,
      streakWarnings: streakWarnings ?? this.streakWarnings,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
    );
  }
}

class ForgeSettingsNotifier extends StateNotifier<ForgeSettingsState> {
  ForgeSettingsNotifier() : super(ForgeSettingsState(intensity: 'Balanced')) {
    _loadSettings();
  }

  static const String _keyIntensity = 'forge_intensity';
  static const String _keyDailyDigests = 'forge_daily_digests';
  static const String _keyStreakWarnings = 'forge_streak_warnings';
  static const String _keyAchievementAlerts = 'forge_achievement_alerts';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      intensity: prefs.getString(_keyIntensity) ?? 'Balanced',
      dailyDigests: prefs.getBool(_keyDailyDigests) ?? true,
      streakWarnings: prefs.getBool(_keyStreakWarnings) ?? true,
      achievementAlerts: prefs.getBool(_keyAchievementAlerts) ?? true,
    );
  }

  Future<void> setIntensity(String intensity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIntensity, intensity);
    state = state.copyWith(intensity: intensity);
  }

  Future<void> toggleDailyDigests(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyDigests, value);
    state = state.copyWith(dailyDigests: value);
  }

  Future<void> toggleStreakWarnings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakWarnings, value);
    state = state.copyWith(streakWarnings: value);
  }

  Future<void> toggleAchievementAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAchievementAlerts, value);
    state = state.copyWith(achievementAlerts: value);
  }
}

final forgeSettingsProvider =
    StateNotifierProvider<ForgeSettingsNotifier, ForgeSettingsState>((ref) {
  return ForgeSettingsNotifier();
});
