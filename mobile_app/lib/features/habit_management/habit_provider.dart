import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/habit_service.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../authentication/auth_provider.dart';

final habitServiceProvider = Provider<HabitService>((ref) => HabitService());

// All user habits stream
final habitsStreamProvider =
    StreamProvider.family<List<HabitModel>, String>((ref, userId) {
  return ref.read(habitServiceProvider).getUserHabits(userId);
});

// Today's logs stream
final todayLogsStreamProvider =
    StreamProvider.family<List<HabitLogModel>, String>((ref, userId) {
  return ref.read(habitServiceProvider).getTodayLogsStream(userId);
});

// Current habit state
final habitNotifierProvider =
    StateNotifierProvider<HabitNotifier, AsyncValue<void>>((ref) {
  return HabitNotifier(ref.read(habitServiceProvider));
});

class HabitNotifier extends StateNotifier<AsyncValue<void>> {
  final HabitService _habitService;

  HabitNotifier(this._habitService) : super(const AsyncValue.data(null));

  Future<HabitModel?> createHabit({
    required String userId,
    required String title,
    required String description,
    required String scheduleType,
    required List<int> scheduleDays,
    required String icon,
    required String color,
    String? reminderTime,
  }) async {
    state = const AsyncValue.loading();
    HabitModel? result;
    state = await AsyncValue.guard(() async {
      result = await _habitService.createHabit(
        userId: userId,
        title: title,
        description: description,
        scheduleType: scheduleType,
        scheduleDays: scheduleDays,
        icon: icon,
        color: color,
        reminderTime: reminderTime,
      );
      return null;
    });
    return result;
  }

  Future<void> updateHabit(HabitModel habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _habitService.updateHabit(habit);
    });
  }

  Future<void> deleteHabit(String habitId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _habitService.deleteHabit(habitId);
    });
  }

  Future<void> toggleHabitCompletion({
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
  }) async {
    await AsyncValue.guard(() async {
      await _habitService.logHabitCompletion(
        habitId: habitId,
        userId: userId,
        date: date,
        completed: completed,
      );
    });
  }
}

// Computed: today's habits with completion status
final todayHabitsProvider = Provider.family<
    AsyncValue<List<({HabitModel habit, bool completed})>>,
    String>((ref, userId) {
  final habitsAsync = ref.watch(habitsStreamProvider(userId));
  final logsAsync = ref.watch(todayLogsStreamProvider(userId));

  return habitsAsync.when(
    data: (habits) {
      return logsAsync.when(
        data: (logs) {
          final todayHabits =
              habits.where((h) => h.isScheduledToday).toList();
          final logMap = {for (final log in logs) log.habitId: log.completed};
          return AsyncValue.data(todayHabits
              .map((h) => (habit: h, completed: logMap[h.habitId] ?? false))
              .toList());
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
// Specific habit logs provider
final habitLogsProvider =
    FutureProvider.family<List<HabitLogModel>, String>((ref, habitId) {
  return ref.read(habitServiceProvider).getHabitLogs(habitId);
});
