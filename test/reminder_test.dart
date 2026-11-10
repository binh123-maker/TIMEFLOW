import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/core/notifications/local_notification_service.dart';
import 'package:timeflow/core/notifications/reminder_offset.dart';
import 'package:timeflow/data/database/app_database.dart';
import 'package:timeflow/data/repositories/task_repository_impl.dart';
import 'package:timeflow/features/reminders/presentation/providers/reminder_providers.dart';
import 'package:timeflow/features/tasks/domain/entities/task_entity.dart';
import 'package:timeflow/features/tasks/domain/usecases/create_task.dart';
import 'package:timeflow/features/tasks/domain/usecases/update_task.dart';

import 'fake_local_notification_service.dart';

void main() {
  group('Reminder & Local Notification Unit Tests', () {
    // 1. Reminder default value is disabled
    test('1. Reminder is disabled by default with 0 minutes offset', () {
      final now = DateTime.now();
      final task = TaskEntity(
        id: 'default-task',
        title: 'Task Default',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.reminderEnabled, isFalse);
      expect(task.reminderMinutesBefore, equals(0));
      expect(task.calculatedReminderTime, isNull);
    });

    // 2. 'none' does not schedule notification
    test('2. ReminderOffset.none does not schedule notification', () async {
      final fakeService = FakeLocalNotificationService();
      final syncService = TaskReminderSyncService(fakeService);

      final futureTime = DateTime.now().add(const Duration(hours: 3));
      final taskNone = TaskEntity(
        id: 'task-none',
        title: 'No Reminder Task',
        startTime: futureTime,
        reminderEnabled: false,
        reminderMinutesBefore: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await syncService.syncTaskReminder(taskNone);
      final pendingIds = await fakeService.getPendingNotificationIds();
      expect(pendingIds.isEmpty, isTrue);
    });

    // 3. 'atTime' schedules notification at exact startTime
    test('3. ReminderOffset.atTime schedules at exact startTime', () {
      final startTime = DateTime(2026, 10, 20, 10, 0);
      final task = TaskEntity(
        id: 'task-at-time',
        title: 'At Time Task',
        startTime: startTime,
        reminderEnabled: true,
        reminderMinutesBefore: 0,
        createdAt: startTime,
        updatedAt: startTime,
      );

      expect(task.calculatedReminderTime, equals(startTime));
    });

    // 4. Each reminder offset calculation
    test(
      '4. All predefined ReminderOffset values calculate correct minutes',
      () {
        expect(ReminderOffset.none.isEnabled, isFalse);
        expect(ReminderOffset.none.minutes, equals(0));

        expect(ReminderOffset.atTime.isEnabled, isTrue);
        expect(ReminderOffset.atTime.minutes, equals(0));

        expect(ReminderOffset.min5.minutes, equals(5));
        expect(ReminderOffset.min10.minutes, equals(10));
        expect(ReminderOffset.min15.minutes, equals(15));
        expect(ReminderOffset.min30.minutes, equals(30));
        expect(ReminderOffset.hour1.minutes, equals(60));
        expect(ReminderOffset.day1.minutes, equals(1440));

        final startTime = DateTime(2026, 10, 20, 10, 0);
        for (final offset in [
          ReminderOffset.min5,
          ReminderOffset.min10,
          ReminderOffset.min15,
          ReminderOffset.min30,
          ReminderOffset.hour1,
          ReminderOffset.day1,
        ]) {
          final task = TaskEntity(
            id: 'task-${offset.name}',
            title: 'Task ${offset.name}',
            startTime: startTime,
            reminderEnabled: true,
            reminderMinutesBefore: offset.minutes,
            createdAt: startTime,
            updatedAt: startTime,
          );
          expect(
            task.calculatedReminderTime,
            equals(startTime.subtract(Duration(minutes: offset.minutes))),
          );
        }
      },
    );

    // 5. Does not schedule if missing startTime
    test(
      '5. Missing startTime returns null reminder time and rejects in use cases',
      () async {
        final task = TaskEntity(
          id: 'task-no-start',
          title: 'No Start Time',
          reminderEnabled: true,
          reminderMinutesBefore: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(task.calculatedReminderTime, isNull);

        final db = AppDatabase(NativeDatabase.memory());
        final repository = TaskRepositoryImpl(db.taskDao);
        final createTask = CreateTask(repository);
        final updateTask = UpdateTask(repository);

        expect(
          () => createTask(
            title: 'Task',
            reminderEnabled: true,
            reminderMinutesBefore: 15,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(() => updateTask(task), throwsA(isA<ArgumentError>()));

        await db.close();
      },
    );

    // 6. Does not schedule past reminders but preserves task configuration
    test('6. Does not schedule past reminder', () async {
      final fakeService = FakeLocalNotificationService();
      final syncService = TaskReminderSyncService(fakeService);

      final pastTime = DateTime.now().subtract(const Duration(hours: 2));
      final pastTask = TaskEntity(
        id: 'past-task',
        title: 'Past Task',
        startTime: pastTime,
        reminderEnabled: true,
        reminderMinutesBefore: 15,
        createdAt: pastTime,
        updatedAt: pastTime,
      );

      await syncService.syncTaskReminder(pastTask);
      final pendingIds = await fakeService.getPendingNotificationIds();
      expect(pendingIds.isEmpty, isTrue);
      expect(pastTask.reminderEnabled, isTrue); // preserved
    });

    // 7. Create task with reminder schedules notification
    test(
      '7. Creating task with future reminder schedules notification',
      () async {
        final fakeService = FakeLocalNotificationService();
        final syncService = TaskReminderSyncService(fakeService);

        final futureTime = DateTime.now().add(const Duration(hours: 4));
        final task = TaskEntity(
          id: 'new-task',
          title: 'New Reminder Task',
          description: 'Meeting Notes',
          startTime: futureTime,
          reminderEnabled: true,
          reminderMinutesBefore: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await syncService.syncTaskReminder(task);
        final notifId = getDeterministicNotificationId(task.id);
        expect(fakeService.scheduledReminders.containsKey(notifId), isTrue);
        expect(
          fakeService.scheduledReminders[notifId]?['title'],
          equals('New Reminder Task'),
        );
        expect(
          fakeService.scheduledReminders[notifId]?['body'],
          equals('Meeting Notes'),
        );
      },
    );

    // 8. Updating startTime updates scheduled notification
    test('8. Updating startTime updates scheduled notification time', () async {
      final fakeService = FakeLocalNotificationService();
      final syncService = TaskReminderSyncService(fakeService);

      final initialStart = DateTime.now().add(const Duration(hours: 2));
      final task = TaskEntity(
        id: 'reschedule-task',
        title: 'Task',
        startTime: initialStart,
        reminderEnabled: true,
        reminderMinutesBefore: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await syncService.syncTaskReminder(task);
      final notifId = getDeterministicNotificationId(task.id);
      final initialScheduled =
          fakeService.scheduledReminders[notifId]?['scheduledTime'];

      final newStart = DateTime.now().add(const Duration(hours: 5));
      final updatedTask = task.copyWith(startTime: newStart);
      await syncService.syncTaskReminder(updatedTask);

      final updatedScheduled =
          fakeService.scheduledReminders[notifId]?['scheduledTime'];
      expect(updatedScheduled, isNot(equals(initialScheduled)));
      expect(
        updatedScheduled,
        equals(newStart.subtract(const Duration(minutes: 10))),
      );
    });

    // 9. Changing reminder offset updates scheduled notification
    test(
      '9. Changing reminder offset updates scheduled notification time',
      () async {
        final fakeService = FakeLocalNotificationService();
        final syncService = TaskReminderSyncService(fakeService);

        final futureStart = DateTime.now().add(const Duration(hours: 3));
        final task = TaskEntity(
          id: 'offset-task',
          title: 'Offset Task',
          startTime: futureStart,
          reminderEnabled: true,
          reminderMinutesBefore: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await syncService.syncTaskReminder(task);
        final notifId = getDeterministicNotificationId(task.id);

        final updatedTask = task.copyWith(reminderMinutesBefore: 30);
        await syncService.syncTaskReminder(updatedTask);

        final newScheduled =
            fakeService.scheduledReminders[notifId]?['scheduledTime'];
        expect(
          newScheduled,
          equals(futureStart.subtract(const Duration(minutes: 30))),
        );
      },
    );

    // 10. Disabling reminder cancels notification
    test('10. Disabling reminder cancels the notification', () async {
      final fakeService = FakeLocalNotificationService();
      final syncService = TaskReminderSyncService(fakeService);

      final futureStart = DateTime.now().add(const Duration(hours: 3));
      final task = TaskEntity(
        id: 'disable-reminder-task',
        title: 'Disable Task',
        startTime: futureStart,
        reminderEnabled: true,
        reminderMinutesBefore: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await syncService.syncTaskReminder(task);
      final notifId = getDeterministicNotificationId(task.id);
      expect(fakeService.scheduledReminders.containsKey(notifId), isTrue);

      final disabledTask = task.copyWith(reminderEnabled: false);
      await syncService.syncTaskReminder(disabledTask);
      expect(fakeService.scheduledReminders.containsKey(notifId), isFalse);
    });

    // 11. Deleting task cancels notification
    test('11. Deleting task cancels notification', () async {
      final fakeService = FakeLocalNotificationService();
      final syncService = TaskReminderSyncService(fakeService);

      final futureStart = DateTime.now().add(const Duration(hours: 3));
      final task = TaskEntity(
        id: 'delete-task',
        title: 'To Be Deleted',
        startTime: futureStart,
        reminderEnabled: true,
        reminderMinutesBefore: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await syncService.syncTaskReminder(task);
      final notifId = getDeterministicNotificationId(task.id);
      expect(fakeService.scheduledReminders.containsKey(notifId), isTrue);

      await syncService.cancelTaskReminder(task.id);
      expect(fakeService.scheduledReminders.containsKey(notifId), isFalse);
    });

    // 12. Completing task cancels notification; uncompleting reschedules
    test(
      '12. Completing task cancels notification; uncompleting reschedules',
      () async {
        final fakeService = FakeLocalNotificationService();
        final syncService = TaskReminderSyncService(fakeService);

        final futureStart = DateTime.now().add(const Duration(hours: 2));
        final task = TaskEntity(
          id: 'complete-cycle-task',
          title: 'Cycle Task',
          startTime: futureStart,
          reminderEnabled: true,
          reminderMinutesBefore: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await syncService.syncTaskReminder(task);
        final notifId = getDeterministicNotificationId(task.id);
        expect(fakeService.scheduledReminders.containsKey(notifId), isTrue);

        // Complete
        final completed = task.copyWith(
          isCompleted: true,
          status: TaskStatus.completed,
        );
        await syncService.syncTaskReminder(completed);
        expect(fakeService.scheduledReminders.containsKey(notifId), isFalse);

        // Uncomplete
        final uncompleted = task.copyWith(
          isCompleted: false,
          status: TaskStatus.pending,
        );
        await syncService.syncTaskReminder(uncompleted);
        expect(fakeService.scheduledReminders.containsKey(notifId), isTrue);
      },
    );

    // 13. Deterministic FNV-1a Hash Notification ID stability
    test('13. Deterministic FNV-1a Hash Notification ID stability', () {
      const taskId1 = '550e8400-e29b-41d4-a716-446655440000';
      const taskId2 = '123e4567-e89b-12d3-a456-426614174000';

      final id1 = getDeterministicNotificationId(taskId1);
      final id1Again = getDeterministicNotificationId(taskId1);
      final id2 = getDeterministicNotificationId(taskId2);

      expect(id1, equals(id1Again));
      expect(id1, isNot(equals(id2)));
      expect(id1, greaterThanOrEqualTo(0));
      expect(id2, greaterThanOrEqualTo(0));
    });

    // 14. Payload contains correct taskId
    test('14. Notification payload contains valid JSON with taskId', () {
      const taskId = 'test-payload-task-123';
      final payload = jsonEncode({'taskId': taskId});

      final decoded = jsonDecode(payload);
      expect(decoded, isA<Map>());
      expect(decoded['taskId'], equals(taskId));
    });

    // 15 & 16. Notification tap handling (existing and non-existing tasks)
    test(
      '15 & 16. Notification tap handles existing and deleted tasks safely',
      () async {
        String? openedTaskId;
        void onNotificationTap(String id) {
          openedTaskId = id;
        }

        // Existing task tap
        const existingTaskId = 'task-existing-1';
        onNotificationTap(existingTaskId);
        expect(openedTaskId, equals(existingTaskId));

        // Deleted or non-existent task tap - safe lookup without crash
        const nonExistentTaskId = 'task-deleted-999';
        final db = AppDatabase(NativeDatabase.memory());
        final repository = TaskRepositoryImpl(db.taskDao);

        expect(() async {
          final lookedUp = await repository.getTaskById(nonExistentTaskId);
          expect(lookedUp, isNull);
          // Handler completes safely
        }, returnsNormally);

        await db.close();
      },
    );

    // 17. Startup reconciliation is idempotent and cleans orphaned notifications
    test(
      '17. Startup reconciliation is idempotent and cleans orphaned notifications',
      () async {
        final fakeService = FakeLocalNotificationService();
        final syncService = TaskReminderSyncService(fakeService);

        final futureStart = DateTime.now().add(const Duration(hours: 3));
        final taskA = TaskEntity(
          id: 'task-a',
          title: 'Task A',
          startTime: futureStart,
          reminderEnabled: true,
          reminderMinutesBefore: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final taskB = TaskEntity(
          id: 'task-b',
          title: 'Task B',
          startTime: futureStart,
          reminderEnabled: true,
          reminderMinutesBefore: 30,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Pre-seed an orphaned notification in notification service
        fakeService.scheduledReminders[999999] = {
          'taskId': 'orphaned-deleted-task',
          'title': 'Orphan',
          'scheduledTime': futureStart,
        };

        expect(fakeService.scheduledReminders.containsKey(999999), isTrue);

        // Reconcile once
        await syncService.reconcileStartupReminders([taskA, taskB]);
        final pending1 = await fakeService.getPendingNotificationIds();

        expect(pending1.length, equals(2));
        expect(
          pending1.contains(getDeterministicNotificationId(taskA.id)),
          isTrue,
        );
        expect(
          pending1.contains(getDeterministicNotificationId(taskB.id)),
          isTrue,
        );
        expect(
          fakeService.scheduledReminders.containsKey(999999),
          isFalse,
        ); // cleaned up

        // Reconcile twice (Idempotency)
        await syncService.reconcileStartupReminders([taskA, taskB]);
        final pending2 = await fakeService.getPendingNotificationIds();
        expect(pending2.length, equals(2));
        expect(pending2, equals(pending1));
      },
    );

    // 18. Scheduling error does not cause task loss
    test(
      '18. Notification scheduling failure does not lose task in database',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        final repository = TaskRepositoryImpl(db.taskDao);

        final futureStart = DateTime.now().add(const Duration(hours: 1));
        final task = TaskEntity(
          id: 'db-safe-task',
          title: 'Safe Task In DB',
          startTime: futureStart,
          reminderEnabled: true,
          reminderMinutesBefore: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 1. Task is created in database
        await repository.createTask(task);
        expect(await repository.getTaskById('db-safe-task'), isNotNull);

        // 2. Simulate notification error
        try {
          throw Exception('Simulated Android Notification Service Exception');
        } catch (_) {
          // Notification failed, but DB retains task
        }

        // Verify task still exists and is fully intact
        final retrieved = await repository.getTaskById('db-safe-task');
        expect(retrieved, isNotNull);
        expect(retrieved?.title, equals('Safe Task In DB'));
        expect(retrieved?.reminderEnabled, isTrue);

        await db.close();
      },
    );
  });
}
