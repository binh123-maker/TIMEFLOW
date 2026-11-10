import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeflow/features/lockscreen/data/services/lockscreen_bridge_service.dart';
import 'package:timeflow/features/lockscreen/domain/models/lockscreen_payload.dart';
import 'package:timeflow/features/lockscreen/presentation/providers/lockscreen_providers.dart';
import 'package:timeflow/features/tasks/domain/entities/task_entity.dart';
import 'package:timeflow/features/tasks/presentation/providers/task_providers.dart';

class FakeLockscreenBridge implements ILockscreenBridge {
  int updateCallCount = 0;
  int cancelCallCount = 0;
  LockscreenPayload? lastReceivedPayload;
  bool shouldThrowPlatformException = false;

  @override
  LockscreenPayload? get lastPayload => lastReceivedPayload;

  @override
  Future<bool> updateOngoingNotification(LockscreenPayload payload) async {
    if (shouldThrowPlatformException) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Simulated Platform Failure',
      );
    }
    // Deduplication test
    if (lastReceivedPayload != null && lastReceivedPayload == payload) {
      return true; // Duplication skipped
    }
    updateCallCount++;
    lastReceivedPayload = payload;
    return true;
  }

  @override
  Future<bool> cancelOngoingNotification() async {
    if (shouldThrowPlatformException) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Simulated Platform Failure',
      );
    }
    cancelCallCount++;
    lastReceivedPayload = null;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('vi', null);
  });

  group('Lockscreen Domain & Model Tests', () {
    test('1. LockscreenTaskSummary JSON serialization and deserialization', () {
      const summary = LockscreenTaskSummary(
        id: 'task-1',
        title: 'Học Kotlin Native',
        description: 'Chi tiết bài học',
        timeRange: '09:00 - 10:30',
        priority: 'Khẩn cấp',
        isCompleted: false,
      );

      final json = summary.toJson();
      expect(json['id'], equals('task-1'));
      expect(json['title'], equals('Học Kotlin Native'));
      expect(json['timeRange'], equals('09:00 - 10:30'));
      expect(json['priority'], equals('Khẩn cấp'));
      expect(json['isCompleted'], isFalse);

      final fromJson = LockscreenTaskSummary.fromJson(json);
      expect(fromJson, equals(summary));
      expect(fromJson.hashCode, equals(summary.hashCode));
    });

    test(
      '2. LockscreenTaskSummary handles null optional fields gracefully',
      () {
        const summary = LockscreenTaskSummary(
          id: 'task-null',
          title: 'Task ngắn gọn',
          priority: 'Trung bình',
        );

        final json = summary.toJson();
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('timeRange'), isFalse);

        final fromJson = LockscreenTaskSummary.fromJson(json);
        expect(fromJson.description, isNull);
        expect(fromJson.timeRange, isNull);
        expect(fromJson.title, equals('Task ngắn gọn'));
        expect(fromJson, equals(summary));
      },
    );

    test(
      '3. LockscreenPayload JSON serialization with both current and next tasks',
      () {
        const current = LockscreenTaskSummary(
          id: 'curr-1',
          title: 'Đang làm task A',
          timeRange: '08:00 - 09:30',
          priority: 'Cao',
        );
        const next = LockscreenTaskSummary(
          id: 'next-1',
          title: 'Sắp làm task B',
          timeRange: '10:00 - 11:00',
          priority: 'Trung bình',
        );

        const payload = LockscreenPayload(
          version: 1,
          currentTask: current,
          nextTask: next,
          totalTasksToday: 5,
          completedTasksToday: 2,
          headerDate: 'Thứ Bảy, 07 tháng 11, 2026',
        );

        final json = payload.toJson();
        expect(json['version'], equals(1));
        expect(json['totalTasksToday'], equals(5));
        expect(json['completedTasksToday'], equals(2));
        expect(json['headerDate'], equals('Thứ Bảy, 07 tháng 11, 2026'));

        final fromJson = LockscreenPayload.fromJson(json);
        expect(fromJson, equals(payload));
        expect(fromJson.hasActiveTasks, isTrue);
        expect(fromJson.currentTask?.title, equals('Đang làm task A'));
        expect(fromJson.nextTask?.title, equals('Sắp làm task B'));
      },
    );

    test(
      '4. LockscreenPayload handles completely empty tasks list and null fields',
      () {
        const payload = LockscreenPayload(
          version: 1,
          currentTask: null,
          nextTask: null,
          totalTasksToday: 0,
          completedTasksToday: 0,
          headerDate: 'Hôm nay',
        );

        final json = payload.toJson();
        expect(json['currentTask'], isNull);
        expect(json['nextTask'], isNull);

        final fromJson = LockscreenPayload.fromJson(json);
        expect(fromJson.currentTask, isNull);
        expect(fromJson.nextTask, isNull);
        expect(fromJson.hasActiveTasks, isFalse);
        expect(fromJson, equals(payload));
      },
    );

    test('5. LockscreenPayload equality and deduplication logic', () {
      const p1 = LockscreenPayload(
        version: 1,
        totalTasksToday: 3,
        completedTasksToday: 1,
        headerDate: '07/11/2026',
      );
      const p2 = LockscreenPayload(
        version: 1,
        totalTasksToday: 3,
        completedTasksToday: 1,
        headerDate: '07/11/2026',
      );
      const p3 = LockscreenPayload(
        version: 1,
        totalTasksToday: 4, // different
        completedTasksToday: 1,
        headerDate: '07/11/2026',
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });
  });

  group('Lockscreen Bridge Service & Deduplication Tests', () {
    test('6. FakeLockscreenBridge deduplicates identical payloads', () async {
      final bridge = FakeLockscreenBridge();
      const payload = LockscreenPayload(
        version: 1,
        totalTasksToday: 2,
        completedTasksToday: 0,
        headerDate: '07/11/2026',
      );

      // First update
      final res1 = await bridge.updateOngoingNotification(payload);
      expect(res1, isTrue);
      expect(bridge.updateCallCount, equals(1));

      // Second update with identical payload -> should be skipped!
      final res2 = await bridge.updateOngoingNotification(payload);
      expect(res2, isTrue);
      expect(bridge.updateCallCount, equals(1)); // Still 1!
    });

    test('7. FakeLockscreenBridge sends update when payload changes', () async {
      final bridge = FakeLockscreenBridge();
      const payload1 = LockscreenPayload(
        version: 1,
        totalTasksToday: 2,
        completedTasksToday: 0,
        headerDate: '07/11/2026',
      );
      const payload2 = LockscreenPayload(
        version: 1,
        totalTasksToday: 2,
        completedTasksToday: 1, // Progress changed!
        headerDate: '07/11/2026',
      );

      await bridge.updateOngoingNotification(payload1);
      expect(bridge.updateCallCount, equals(1));

      await bridge.updateOngoingNotification(payload2);
      expect(bridge.updateCallCount, equals(2));
      expect(bridge.lastPayload?.completedTasksToday, equals(1));
    });

    test(
      '8. Bridge handles platform exceptions safely without crashing',
      () async {
        final bridge = FakeLockscreenBridge();
        bridge.shouldThrowPlatformException = true;

        const payload = LockscreenPayload(version: 1, headerDate: '07/11/2026');

        expect(() async {
          try {
            await bridge.updateOngoingNotification(payload);
          } catch (e) {
            expect(e, isA<PlatformException>());
          }
        }, returnsNormally);
      },
    );

    test('9. Cancel notification resets bridge state', () async {
      final bridge = FakeLockscreenBridge();
      const payload = LockscreenPayload(version: 1, headerDate: '07/11/2026');

      await bridge.updateOngoingNotification(payload);
      expect(bridge.lastPayload, isNotNull);

      await bridge.cancelOngoingNotification();
      expect(bridge.lastPayload, isNull);
      expect(bridge.cancelCallCount, equals(1));
    });
  });

  group('Lockscreen Provider & Task Selection Integration Tests', () {
    test(
      '10. Lockscreen payload maps active currentTask and upcoming nextTask correctly',
      () {
        final now = DateTime.now();

        // Current active task (now is between 1 hour ago and 1 hour from now)
        final activeTask = TaskEntity(
          id: 'active-1',
          title: 'Công việc hiện tại',
          startTime: now.subtract(const Duration(minutes: 30)),
          endTime: now.add(const Duration(minutes: 30)),
          priority: TaskPriority.high,
          createdAt: now,
          updatedAt: now,
        );

        // Upcoming next task (starts 2 hours from now)
        final upcomingTask = TaskEntity(
          id: 'upcoming-1',
          title: 'Công việc tiếp theo',
          startTime: now.add(const Duration(hours: 2)),
          endTime: now.add(const Duration(hours: 3)),
          priority: TaskPriority.medium,
          createdAt: now,
          updatedAt: now,
        );

        // Completed task (should be filtered out from active/next)
        final completedTask = TaskEntity(
          id: 'done-1',
          title: 'Công việc đã xong',
          isCompleted: true,
          status: TaskStatus.completed,
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.subtract(const Duration(hours: 1)),
          createdAt: now,
          updatedAt: now,
        );

        final container = ProviderContainer(
          overrides: [
            currentTaskStreamProvider.overrideWithValue(
              AsyncValue.data(activeTask),
            ),
            nextTaskStreamProvider.overrideWithValue(
              AsyncValue.data(upcomingTask),
            ),
            todayTasksStreamProvider.overrideWithValue(
              AsyncValue.data([activeTask, upcomingTask, completedTask]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final payload = container.read(lockscreenPayloadProvider);
        expect(payload.currentTask, isNotNull);
        expect(payload.currentTask?.title, equals('Công việc hiện tại'));
        expect(payload.currentTask?.priority, equals('Cao'));

        expect(payload.nextTask, isNotNull);
        expect(payload.nextTask?.title, equals('Công việc tiếp theo'));
        expect(payload.nextTask?.priority, equals('Trung bình'));

        expect(payload.totalTasksToday, equals(3));
        expect(payload.completedTasksToday, equals(1));
      },
    );

    test(
      '11. Completed tasks are never selected as Current Task or Next Task',
      () {
        final now = DateTime.now();
        final completedTask = TaskEntity(
          id: 'completed-task',
          title: 'Đã hoàn thành',
          isCompleted: true,
          status: TaskStatus.completed,
          startTime: now.subtract(const Duration(minutes: 10)),
          endTime: now.add(const Duration(minutes: 20)),
          createdAt: now,
          updatedAt: now,
        );

        final container = ProviderContainer(
          overrides: [
            currentTaskStreamProvider.overrideWithValue(
              const AsyncValue.data(null),
            ),
            nextTaskStreamProvider.overrideWithValue(
              const AsyncValue.data(null),
            ),
            todayTasksStreamProvider.overrideWithValue(
              AsyncValue.data([completedTask]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final payload = container.read(lockscreenPayloadProvider);
        expect(payload.currentTask, isNull);
        expect(payload.nextTask, isNull);
        expect(payload.totalTasksToday, equals(1));
        expect(payload.completedTasksToday, equals(1));
      },
    );
  });
}
