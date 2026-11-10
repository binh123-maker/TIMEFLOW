import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/services/lockscreen_bridge_service.dart';
import '../../domain/models/lockscreen_payload.dart';

/// Provider for Lockscreen Bridge service abstraction
final lockscreenBridgeProvider = Provider<ILockscreenBridge>((ref) {
  return MethodChannelLockscreenBridge();
});

/// Formats a TaskEntity into a LockscreenTaskSummary
LockscreenTaskSummary _mapTaskToSummary(TaskEntity task) {
  String? timeRange;
  if (task.startTime != null && task.endTime != null) {
    timeRange = DateFormatter.formatTimeRange(task.startTime!, task.endTime!);
  } else if (task.startTime != null) {
    timeRange = DateFormatter.formatTime(task.startTime!);
  }

  return LockscreenTaskSummary(
    id: task.id,
    title: task.title,
    description: task.description,
    timeRange: timeRange,
    priority: task.priority.displayName,
    isCompleted: task.isCompleted,
  );
}

/// Computes LockscreenPayload from current, next and today tasks
final lockscreenPayloadProvider = Provider<LockscreenPayload>((ref) {
  final currentTask = ref.watch(currentTaskStreamProvider).value;
  final nextTask = ref.watch(nextTaskStreamProvider).value;
  final todayTasks = ref.watch(todayTasksStreamProvider).value ?? [];

  final totalCount = todayTasks.length;
  final completedCount = todayTasks.where((t) => t.isCompleted).length;
  final dateFormatted = DateFormatter.formatHeaderDate(DateTime.now());

  return LockscreenPayload(
    version: 1,
    currentTask: currentTask != null ? _mapTaskToSummary(currentTask) : null,
    nextTask: nextTask != null ? _mapTaskToSummary(nextTask) : null,
    totalTasksToday: totalCount,
    completedTasksToday: completedCount,
    headerDate: dateFormatted,
  );
});

/// Reactive Auto-Sync Listener synchronizing Task changes to Android Lockscreen Notification
final lockscreenAutoSyncListenerProvider = Provider<void>((ref) {
  ref.listen<LockscreenPayload>(lockscreenPayloadProvider, (previous, next) {
    ref.read(lockscreenBridgeProvider).updateOngoingNotification(next);
  });
});
