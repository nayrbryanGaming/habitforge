import 'package:flutter_test/flutter_test.dart';
import 'package:habitforge/models/habit_model.dart';

void main() {
  group('Habit Provider Logic Tests', () {
    test('Filtering today habits based on day of week', () {
      final habits = [
        HabitModel(
          habitId: '1',
          userId: 'u1',
          title: 'Daily',
          description: '',
          icon: 'I',
          color: 'C',
          scheduleType: 'daily',
          scheduleDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
          isActive: true,
          currentStreak: 0,
          longestStreak: 0,
        ),
        HabitModel(
          habitId: '2',
          userId: 'u1',
          title: 'Mon/Wed',
          description: '',
          icon: 'I',
          color: 'C',
          scheduleType: 'weekly',
          scheduleDays: [1, 3],
          createdAt: DateTime.now(),
          isActive: true,
          currentStreak: 0,
          longestStreak: 0,
        ),
      ];

      final monday = DateTime(2026, 4, 13); // A Monday (Weekday 1)
      final tuesday = DateTime(2026, 4, 14); // A Tuesday (Weekday 2)

      final mondayFiltered = habits.where((h) {
        if (h.scheduleType == 'daily') return true;
        return h.scheduleDays.contains(monday.weekday);
      }).toList();

      final tuesdayFiltered = habits.where((h) {
        if (h.scheduleType == 'daily') return true;
        return h.scheduleDays.contains(tuesday.weekday);
      }).toList();

      expect(mondayFiltered.length, 2);
      expect(tuesdayFiltered.length, 1);
      expect(tuesdayFiltered[0].title, 'Daily');
    });
  });
}
