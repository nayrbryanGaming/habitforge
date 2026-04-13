import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';
import '../constants/app_constants.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Habit
  Future<HabitModel> createHabit({
    required String userId,
    required String title,
    required String description,
    required String scheduleType,
    required List<int> scheduleDays,
    required String icon,
    required String color,
    String? reminderTime,
  }) async {
    final docRef = _firestore
        .collection(AppConstants.habitsCollection)
        .doc();

    final habit = HabitModel(
      habitId: docRef.id,
      userId: userId,
      title: title,
      description: description,
      scheduleType: scheduleType,
      scheduleDays: scheduleDays,
      icon: icon,
      color: color,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
      isActive: true,
      currentStreak: 0,
      longestStreak: 0,
    );

    await docRef.set(habit.toJson());
    return habit;
  }

  // Get User Habits (Stream with Local Cache)
  Stream<List<HabitModel>> getUserHabits(String userId) async* {
    final box = Hive.box('habits_cache');
    
    // Yield cached data first
    final cached = box.get(userId);
    if (cached != null) {
      yield (cached as List).map((e) => HabitModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    try {
      final snapStream = _firestore
          .collection(AppConstants.habitsCollection)
          .where('user_id', isEqualTo: userId)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: false)
          .snapshots();

      await for (final snap in snapStream) {
        final habits = snap.docs
            .map((doc) => HabitModel.fromJson({'habit_id': doc.id, ...doc.data()}))
            .toList();
        
        // Cache to Hive
        await box.put(userId, habits.map((h) => h.toJson()).toList());
        yield habits;
      }
    } catch (e) {
      if (cached == null) yield [];
      // Silently fail if offline, we've already yielded cache
    }
  }

  // Update Habit
  Future<void> updateHabit(HabitModel habit) async {
    await _firestore
        .collection(AppConstants.habitsCollection)
        .doc(habit.habitId)
        .update(habit.toJson());
  }

  // Delete (soft-delete) Habit
  Future<void> deleteHabit(String habitId) async {
    await _firestore
        .collection(AppConstants.habitsCollection)
        .doc(habitId)
        .update({'is_active': false});
  }

  // Log Habit Completion
  Future<void> logHabitCompletion({
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
  }) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final logId = '${habitId}_$dateStr';

    final log = HabitLogModel(
      logId: logId,
      habitId: habitId,
      userId: userId,
      date: date,
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    );

    // Update Local Cache
    final box = Hive.box('logs_cache');
    await box.put(logId, log.toJson());

    try {
      await _firestore
          .collection(AppConstants.habitLogsCollection)
          .doc(logId)
          .set(log.toJson(), SetOptions(merge: true));

      // Update streak
      await _updateStreak(habitId, userId);
    } catch (e) {
      // If offline, we've already saved locally. 
      // A sync mechanism could be added for later background sync.
      debugPrint('Offline: Saved log locally.');
    }
  }

  // Get Today's Logs
  Future<Map<String, bool>> getTodayLogs(String userId) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final habits = await _firestore
        .collection(AppConstants.habitsCollection)
        .where('user_id', isEqualTo: userId)
        .where('is_active', isEqualTo: true)
        .get();

    final box = Hive.box('logs_cache');
    final results = <String, bool>{};

    for (final habit in habits.docs) {
      final habitId = habit.id;
      final logId = '${habitId}_$dateStr';
      
      // Try cache first
      final cached = box.get(logId);
      if (cached != null) {
        results[habitId] = (cached as Map)['completed'] ?? false;
        continue;
      }

      try {
        final logDoc = await _firestore
            .collection(AppConstants.habitLogsCollection)
            .doc(logId)
            .get();
        final completed = logDoc.exists ? (logDoc.data()?['completed'] ?? false) : false;
        results[habitId] = completed;
        
        // Cache it
        if (logDoc.exists) await box.put(logId, logDoc.data());
      } catch (e) {
        results[habitId] = false;
      }
    }

    return results;
  }

  // Get Logs Stream for Today
  Stream<List<HabitLogModel>> getTodayLogsStream(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(AppConstants.habitLogsCollection)
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => HabitLogModel.fromJson({'log_id': doc.id, ...doc.data()}))
            .toList());
  }

  // Get Weekly Logs
  Future<List<HabitLogModel>> getWeeklyLogs(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final snap = await _firestore
        .collection(AppConstants.habitLogsCollection)
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .get();

    return snap.docs
        .map((doc) => HabitLogModel.fromJson({'log_id': doc.id, ...doc.data()}))
        .toList();
  }

  // Get Monthly Logs
  Future<List<HabitLogModel>> getMonthlyLogs(String userId) async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final snap = await _firestore
        .collection(AppConstants.habitLogsCollection)
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthAgo))
        .get();

    return snap.docs
        .map((doc) => HabitLogModel.fromJson({'log_id': doc.id, ...doc.data()}))
        .toList();
  }

  // Update Streak (Optimized)
  Future<void> _updateStreak(String habitId, String userId) async {
    final trackingService = HabitTrackingService();
    final results = await trackingService.calculateStreaks(habitId, userId);

    await _firestore
        .collection(AppConstants.habitsCollection)
        .doc(habitId)
        .update({
      'current_streak': results['currentStreak'],
      'longest_streak': results['longestStreak'],
    });
  }

  // Get Habit by ID
  Future<HabitModel?> getHabitById(String habitId) async {
    final doc = await _firestore
        .collection(AppConstants.habitsCollection)
        .doc(habitId)
        .get();

    if (!doc.exists) return null;
    return HabitModel.fromJson({'habit_id': doc.id, ...doc.data()!});
  }

  // Get Logs for a Specific Habit (last 30 days)
  Future<List<HabitLogModel>> getHabitLogs(String habitId) async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final snap = await _firestore
        .collection(AppConstants.habitLogsCollection)
        .where('habit_id', isEqualTo: habitId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthAgo))
        .orderBy('date', descending: true)
        .get();

    return snap.docs
        .map((doc) => HabitLogModel.fromJson({'log_id': doc.id, ...doc.data()}))
        .toList();
  }
}
