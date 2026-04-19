import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLogModel {
  final String logId;
  final String habitId;
  final String userId;
  final DateTime date;
  final String dateString;
  final bool completed;
  final DateTime? completedAt;
  final bool synced;

  const HabitLogModel({
    required this.logId,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.dateString,
    required this.completed,
    this.completedAt,
    this.synced = true,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      logId: json['log_id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date'] as String),
      dateString: json['date_string'] as String? ?? (json['date'] is Timestamp 
          ? (json['date'] as Timestamp).toDate().toIso8601String().split('T')[0]
          : (json['date'] as String).split('T')[0]),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] is Timestamp
              ? (json['completed_at'] as Timestamp).toDate()
              : DateTime.parse(json['completed_at'] as String))
          : null,
      synced: json['synced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'habit_id': habitId,
      'user_id': userId,
      'date': Timestamp.fromDate(date),
      'date_string': dateString,
      'completed': completed,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'synced': synced,
    };
  }

  HabitLogModel copyWith({
    String? logId,
    String? habitId,
    String? userId,
    DateTime? date,
    String? dateString,
    bool? completed,
    DateTime? completedAt,
    bool? synced,
  }) {
    return HabitLogModel(
      logId: logId ?? this.logId,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      dateString: dateString ?? this.dateString,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      synced: synced ?? this.synced,
    );
  }
}
