import 'package:flutter_test/flutter_test.dart';
import 'package:habitforge/models/habit_model.dart';

void main() {
  group('HabitModel Tests', () {
    final testHabit = HabitModel(
      habitId: '1',
      userId: 'user1',
      title: 'Workout',
      description: 'Morning gym',
      icon: '🏋️',
      color: '#FF0000',
      scheduleType: 'daily',
      scheduleDays: [1, 2, 3, 4, 5, 6, 7],
      createdAt: DateTime(2026, 1, 1),
    );

    test('HabitModel fromJson/toJson should remain consistent', () {
      final json = testHabit.toJson();
      final fromJson = HabitModel.fromJson(json);

      expect(fromJson.habitId, testHabit.habitId);
      expect(fromJson.title, testHabit.title);
      expect(fromJson.scheduleDays, testHabit.scheduleDays);
    });

    test('copyWith should update fields correctly', () {
      final updated = testHabit.copyWith(title: 'Updated Workout', currentStreak: 5);

      expect(updated.title, 'Updated Workout');
      expect(updated.currentStreak, 5);
      expect(updated.habitId, testHabit.habitId); // Should remain same
    });

    test('Default values are set correctly', () {
      final habit = HabitModel(
        habitId: '2',
        userId: 'u2',
        title: 'T',
        icon: 'I',
        color: 'C',
        scheduleType: 'S',
        scheduleDays: [],
        createdAt: DateTime.now(),
      );

      expect(habit.currentStreak, 0);
      expect(habit.longestStreak, 0);
    });
  });
}
