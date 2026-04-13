import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';
import '../constants/app_constants.dart';

class HabitTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Optimized streak calculation.
  /// Instead of individual reads, we fetch logs in batches.
  Future<Map<String, int>> calculateStreaks(String habitId, String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Fetch last 90 logs to calculate current streak
    final snap = await _firestore
        .collection(AppConstants.habitLogsCollection)
        .where('habit_id', isEqualTo: habitId)
        .where('completed', isEqualTo: true)
        .orderBy('date', descending: true)
        .limit(90)
        .get();

    final logs = snap.docs
        .map((doc) => HabitLogModel.fromJson({'log_id': doc.id, ...doc.data()}))
        .toList();

    int currentStreak = 0;
    DateTime checkDate = today;

    for (var log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      
      // If log is today or yesterday (to handle if today isn't done yet)
      if (logDate == checkDate || logDate == checkDate.subtract(const Duration(days: 1))) {
        currentStreak++;
        checkDate = logDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Also fetch the habit to check longest streak
    final habitDoc = await _firestore.collection(AppConstants.habitsCollection).doc(habitId).get();
    final habit = HabitModel.fromJson({'habit_id': habitDoc.id, ...habitDoc.data()!});
    
    int longestStreak = habit.longestStreak;
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
