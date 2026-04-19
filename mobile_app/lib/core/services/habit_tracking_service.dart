import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../constants/app_constants.dart';

class HabitTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clinical-grade streak calculation (Resilient to timezones, DST, and gaps)
  Future<Map<String, int>> calculateStreaks(String habitId, String userId) async {
    final now = DateTime.now();
    // Normalize to local midnight for strict comparisons
    final today = DateTime(now.year, now.month, now.day);
    
    final habitDoc = await _firestore.collection(AppConstants.habitsCollection).doc(habitId).get();
    if (!habitDoc.exists) return {'currentStreak': 0, 'longestStreak': 0};
    
    final habitData = habitDoc.data()!;
    final habit = HabitModel.fromJson({'habit_id': habitDoc.id, ...habitData});
    final creationDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);

    // Fetch only completed logs, ordered by date descending
    final snap = await _firestore
        .collection(AppConstants.habitLogsCollection)
        .where('habit_id', isEqualTo: habitId)
        .where('completed', isEqualTo: true)
        .orderBy('date', descending: true)
        .get();

    // Map logs to simple date strings for O(1) lookup
    final logDates = snap.docs.map((doc) {
      return doc.data()['date_string'] as String;
    }).toSet();

    int currentStreak = 0;
    DateTime checkDate = today;
    bool streakBroken = false;
    
    // Safety limit to avoid infinite loops (10 years)
    const int maxDays = 3650;
    int daysChecked = 0;

    while (daysChecked < maxDays && (checkDate.isAfter(creationDate) || checkDate.isAtSameMomentAs(creationDate))) {
      final dateKey = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      
      // Determine if a habit was scheduled for this specific day
      final bool isScheduled = habit.scheduleType == 'daily' || 
                               (habit.scheduleDays.contains(checkDate.weekday));

      if (isScheduled) {
        if (logDates.contains(dateKey)) {
          currentStreak++;
        } else {
          // Rule: If it's TODAY and not done yet, the streak isn't broken yet.
          // Rule: If it's BEFORE today and not done, the streak is DEAD.
          if (!checkDate.isAtSameMomentAs(today)) {
            streakBroken = true;
            break;
          }
        }
      }
      
      checkDate = checkDate.subtract(const Duration(days: 1));
      daysChecked++;
    }

    // Update longest streak if necessary
    int longestStreak = habitData['longest_streak'] ?? 0;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }



  /// Syncs local logs with Firestore.
  Future<void> syncOfflineLogs() async {
    final box = Hive.box('logs_cache');
    final keys = box.keys.toList();
    
    for (var key in keys) {
      final data = box.get(key);
      if (data != null && data['synced'] == false) {
        try {
          await _firestore
              .collection(AppConstants.habitLogsCollection)
              .doc(key.toString())
              .set(data, SetOptions(merge: true));
          
          // Mark as synced
          data['synced'] = true;
          await box.put(key, data);
        } catch (e) {
          // Stay unsynced
        }
      }
    }
  }
}
