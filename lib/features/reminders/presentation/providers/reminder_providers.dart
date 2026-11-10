import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

/// Provider for ILocalNotificationService abstraction
final localNotificationServiceProvider = Provider<ILocalNotificationService>((
  ref,
) {
  return FlutterLocalNotificationService();
});

/// Service managing Task <-> Local Notification Synchronization
class TaskReminderSyncService {
  final ILocalNotificationService _notificationService;

  TaskReminderSyncService(this._notificationService);

  /// Synchronize notification for a single Task (Create / Update / Complete / Uncomplete)
  Future<void> syncTaskReminder(TaskEntity task) async {
    final scheduledTime = task.calculatedReminderTime;

    if (!task.isCompleted &&
        task.status != TaskStatus.cancelled &&
        task.reminderEnabled &&
        scheduledTime != null &&
        scheduledTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleTaskReminder(
        taskId: task.id,
        title: task.title,
        body: task.description,
        scheduledTime: scheduledTime,
      );
    } else {
      await _notificationService.cancelTaskReminder(task.id);
    }
  }

  /// Cancel notification when a Task is deleted
  Future<void> cancelTaskReminder(String taskId) async {
    await _notificationService.cancelTaskReminder(taskId);
  }

  /// Idempotent Startup Reconciliation: Reconciles all pending local notifications with SQLite tasks
  Future<void> reconcileStartupReminders(List<TaskEntity> tasks) async {
    final pendingIds = await _notificationService.getPendingNotificationIds();

    final validActiveNotificationIds = <int>{};

    for (final task in tasks) {
      final notifId = getDeterministicNotificationId(task.id);
      final scheduledTime = task.calculatedReminderTime;

      final isShouldBeActive =
          !task.isCompleted &&
          task.status != TaskStatus.cancelled &&
          task.reminderEnabled &&
          scheduledTime != null &&
          scheduledTime.isAfter(DateTime.now());

      if (isShouldBeActive) {
        validActiveNotificationIds.add(notifId);
        await _notificationService.scheduleTaskReminder(
          taskId: task.id,
          title: task.title,
          body: task.description,
          scheduledTime: scheduledTime,
        );
      } else {
        if (pendingIds.contains(notifId)) {
          await _notificationService.cancelTaskReminder(task.id);
        }
      }
    }

    // Clean up orphaned pending notifications
    for (final pendingId in pendingIds) {
      if (!validActiveNotificationIds.contains(pendingId)) {
        await _notificationService.cancelNotificationById(pendingId);
      }
    }
  }
}

/// Provider for TaskReminderSyncService
final taskReminderSyncServiceProvider = Provider<TaskReminderSyncService>((
  ref,
) {
  final notificationService = ref.watch(localNotificationServiceProvider);
  return TaskReminderSyncService(notificationService);
});

/// Reactive Auto-Reconciliation Listener connecting allTasksStreamProvider to Local Notifications
final appReminderSyncListenerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<TaskEntity>>>(allTasksStreamProvider, (
    previous,
    next,
  ) {
    next.whenData((tasks) {
      ref
          .read(taskReminderSyncServiceProvider)
          .reconcileStartupReminders(tasks);
    });
  });
});
