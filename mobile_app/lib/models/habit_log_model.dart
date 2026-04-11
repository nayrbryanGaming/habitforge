import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLogModel {
  final String logId;
  final String habitId;
  final String userId;
  final DateTime date;
  final bool completed;
  final DateTime? completedAt;

  const HabitLogModel({
    required this.logId,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completed,
    this.completedAt,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      logId: json['log_id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] is Timestamp
              ? (json['completed_at'] as Timestamp).toDate()
              : DateTime.parse(json['completed_at'] as String))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'habit_id': habitId,
      'user_id': userId,
      'date': Timestamp.fromDate(date),
      'completed': completed,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
