import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String habitId;
  final String userId;
  final String title;
  final String description;
  final String scheduleType; // 'daily' | 'weekly'
  final List<int> scheduleDays; // 1=Mon...7=Sun
  final String icon;
  final String color;
  final String? reminderTime; // "HH:mm"
  final DateTime createdAt;
  final bool isActive;
  final int currentStreak;
  final int longestStreak;

  const HabitModel({
    required this.habitId,
    required this.userId,
    required this.title,
    required this.description,
    required this.scheduleType,
    required this.scheduleDays,
    required this.icon,
    required this.color,
    this.reminderTime,
    required this.createdAt,
    required this.isActive,
    required this.currentStreak,
    required this.longestStreak,
  });

  bool get isDaily => scheduleType == 'daily';
  bool get isScheduledToday {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    return isDaily || scheduleDays.contains(today);
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      scheduleType: json['schedule_type'] as String? ?? 'daily',
      scheduleDays: (json['schedule_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
      icon: json['icon'] as String? ?? '✅',
      color: json['color'] as String? ?? '#2563EB',
      reminderTime: json['reminder_time'] as String?,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'user_id': userId,
      'title': title,
      'description': description,
      'schedule_type': scheduleType,
      'schedule_days': scheduleDays,
      'icon': icon,
      'color': color,
      'reminder_time': reminderTime,
      'created_at': Timestamp.fromDate(createdAt),
      'is_active': isActive,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  HabitModel copyWith({
    String? habitId,
    String? userId,
    String? title,
    String? description,
    String? scheduleType,
    List<int>? scheduleDays,
    String? icon,
    String? color,
    String? reminderTime,
    DateTime? createdAt,
    bool? isActive,
    int? currentStreak,
    int? longestStreak,
  }) {
    return HabitModel(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}
