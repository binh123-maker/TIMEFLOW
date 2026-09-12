import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

/// StateNotifier for selected calendar date
class SelectedDateNotifier extends StateNotifier<DateTime> {
  SelectedDateNotifier() : super(_todayDate());

  static DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void selectDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void selectToday() {
    state = _todayDate();
  }
}

final selectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, DateTime>((ref) {
      return SelectedDateNotifier();
    });

/// StateNotifier for displayed calendar month (year, month)
class DisplayedMonthNotifier extends StateNotifier<DateTime> {
  DisplayedMonthNotifier() : super(_currentMonth());

  static DateTime _currentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime monthDate) {
    state = DateTime(monthDate.year, monthDate.month);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void selectCurrentMonth() {
    state = _currentMonth();
  }
}

final displayedMonthProvider =
    StateNotifierProvider<DisplayedMonthNotifier, DateTime>((ref) {
      return DisplayedMonthNotifier();
    });

/// Derived Stream Provider for Tasks matching selectedDate
final selectedDateTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final allTasksAsync = ref.watch(allTasksStreamProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return allTasksAsync.whenData((tasks) {
    // 1. Filter by dueDate matching selectedDate (ignoring time components)
    final dateTasks = tasks
        .where((t) => DateFormatter.isSameDay(t.dueDate, selectedDate))
        .toList();

    // 2. Sort: Timed tasks first (startTime ASC -> createdAt ASC), then untimed tasks (createdAt ASC)
    dateTasks.sort((a, b) {
      if (a.startTime != null && b.startTime != null) {
        final cmp = a.startTime!.compareTo(b.startTime!);
        if (cmp != 0) return cmp;
        return a.createdAt.compareTo(b.createdAt);
      }
      if (a.startTime != null && b.startTime == null) {
        return -1; // Timed tasks come before untimed tasks
      }
      if (a.startTime == null && b.startTime != null) {
        return 1; // Untimed tasks come after timed tasks
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    return dateTasks;
  });
});

/// Derived Provider mapping normalized DateTime(year, month, day) -> count of tasks
final monthTaskCountsProvider = Provider<AsyncValue<Map<DateTime, int>>>((ref) {
  final allTasksAsync = ref.watch(allTasksStreamProvider);

  return allTasksAsync.whenData((tasks) {
    final Map<DateTime, int> counts = {};

    for (final task in tasks) {
      if (task.dueDate != null) {
        final key = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    return counts;
  });
});
