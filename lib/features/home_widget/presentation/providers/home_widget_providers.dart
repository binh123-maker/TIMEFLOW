import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/services/home_widget_service.dart';
import '../../domain/models/home_widget_payload.dart';

/// Service provider for Home Screen Widgets
final homeWidgetServiceProvider = Provider<IHomeWidgetService>((ref) {
  return HomeWidgetServiceImpl();
});

/// Computes the next time-based transition point among today's tasks
DateTime? calculateNextTransitionTime(List<TaskEntity> tasks, DateTime now) {
  DateTime? earliest;
  for (final t in tasks) {
    if (t.isCompleted || t.status == TaskStatus.completed) continue;
    if (t.startTime != null && t.startTime!.isAfter(now)) {
      if (earliest == null || t.startTime!.isBefore(earliest)) {
        earliest = t.startTime;
      }
    }
    if (t.endTime != null && t.endTime!.isAfter(now)) {
      if (earliest == null || t.endTime!.isBefore(earliest)) {
        earliest = t.endTime;
      }
    }
  }
  return earliest;
}

int _priorityWeight(TaskPriority p) {
  switch (p) {
    case TaskPriority.urgent:
      return 4;
    case TaskPriority.high:
      return 3;
    case TaskPriority.medium:
      return 2;
    case TaskPriority.low:
      return 1;
  }
}

/// Pure helper to extract Current Task and Next Task at an exact moment in time [now]
///
/// Overlapping Task Rule (Deterministic Priority Resolution):
/// - For Current Task: If multiple uncompleted tasks overlap with [now], the task with the
///   highest priority weight (urgent > high > medium > low) is selected. Ties are broken by
///   earlier startTime, then earlier endTime, then createdAt DESC.
/// - For Next Task: Candidates with startTime strictly after [now] are sorted by
///   startTime ASC, then priority weight DESC, then createdAt DESC.
({TaskEntity? currentTask, TaskEntity? nextTask}) evaluateCurrentAndNextTask(
  List<TaskEntity> tasks,
  DateTime now,
) {
  final activeCandidates = <TaskEntity>[];
  final upcomingCandidates = <TaskEntity>[];

  for (final t in tasks) {
    if (t.isCompleted || t.status == TaskStatus.completed) continue;

    if (t.startTime != null && t.endTime != null) {
      final isStarted =
          t.startTime!.isBefore(now) || t.startTime!.isAtSameMomentAs(now);
      final isNotEnded = t.endTime!.isAfter(now);
      if (isStarted && isNotEnded) {
        activeCandidates.add(t);
        continue;
      }
    }

    if (t.startTime != null && t.startTime!.isAfter(now)) {
      upcomingCandidates.add(t);
    }
  }

  // Sort active candidates by priority DESC, startTime ASC, endTime ASC
  activeCandidates.sort((a, b) {
    final pComp = _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
    if (pComp != 0) return pComp;
    final startComp = a.startTime!.compareTo(b.startTime!);
    if (startComp != 0) return startComp;
    return a.endTime!.compareTo(b.endTime!);
  });

  // Sort upcoming candidates by startTime ASC, priority DESC
  upcomingCandidates.sort((a, b) {
    final startComp = a.startTime!.compareTo(b.startTime!);
    if (startComp != 0) return startComp;
    return _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
  });

  return (
    currentTask: activeCandidates.isNotEmpty ? activeCandidates.first : null,
    nextTask: upcomingCandidates.isNotEmpty ? upcomingCandidates.first : null,
  );
}

/// Helper mapping TaskEntity to HomeWidgetTaskSummary
HomeWidgetTaskSummary mapTaskToWidgetSummary(TaskEntity task) {
  String? timeRange;
  if (task.startTime != null && task.endTime != null) {
    timeRange = DateFormatter.formatTimeRange(task.startTime!, task.endTime!);
  } else if (task.startTime != null) {
    timeRange = DateFormatter.formatTime(task.startTime!);
  }

  return HomeWidgetTaskSummary(
    id: task.id,
    title: task.title,
    description: task.description,
    timeRange: timeRange,
    priority: task.priority.displayName,
    isCompleted: task.isCompleted,
  );
}

/// Dynamic clock stream ticking at exact task transition boundaries or minute flips
final homeWidgetClockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();

  while (true) {
    final now = DateTime.now();
    final todayTasks = ref.watch(todayTasksStreamProvider).value ?? [];
    final nextTransition = calculateNextTransitionTime(todayTasks, now);

    // Delay until either next task boundary or next minute boundary, whichever is sooner
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    final targetTime =
        (nextTransition != null && nextTransition.isBefore(nextMinute))
        ? nextTransition
        : nextMinute;

    final duration = targetTime.difference(DateTime.now());
    if (duration > Duration.zero) {
      await Future.delayed(duration);
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }

    yield DateTime.now();
  }
});

/// Reactive Provider computing HomeWidgetPayload from Drift SQLite stream + transition clock
final homeWidgetPayloadProvider = Provider<HomeWidgetPayload>((ref) {
  final clock = ref.watch(homeWidgetClockProvider).value ?? DateTime.now();
  final allTodayTasks = ref.watch(todayTasksStreamProvider).value ?? [];

  // Filter tasks to match clock day (guarantees clean midnight transition without yesterday's tasks)
  final todayTasks = allTodayTasks.where((t) {
    if (t.dueDate != null) {
      return t.dueDate!.year == clock.year &&
          t.dueDate!.month == clock.month &&
          t.dueDate!.day == clock.day;
    }
    if (t.startTime != null) {
      return t.startTime!.year == clock.year &&
          t.startTime!.month == clock.month &&
          t.startTime!.day == clock.day;
    }
    return true;
  }).toList();

  final totalCount = todayTasks.length;
  final completedCount = todayTasks.where((t) => t.isCompleted).length;
  final dateFormatted = DateFormatter.formatHeaderDate(clock);

  final evaluated = evaluateCurrentAndNextTask(todayTasks, clock);

  return HomeWidgetPayload(
    version: 1,
    currentTask: evaluated.currentTask != null
        ? mapTaskToWidgetSummary(evaluated.currentTask!)
        : null,
    nextTask: evaluated.nextTask != null
        ? mapTaskToWidgetSummary(evaluated.nextTask!)
        : null,
    totalTasksToday: totalCount,
    completedTasksToday: completedCount,
    headerDate: dateFormatted,
    lastUpdatedAt: clock,
  );
});

/// Reactive Auto-Sync Listener synchronizing changes to Android Home Screen Widgets
final homeWidgetAutoSyncListenerProvider = Provider<void>((ref) {
  ref.listen<HomeWidgetPayload>(homeWidgetPayloadProvider, (previous, next) {
    ref.read(homeWidgetServiceProvider).updateWidgets(next);
  });
});
