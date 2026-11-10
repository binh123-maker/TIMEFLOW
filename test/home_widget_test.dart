import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeflow/features/home_widget/data/services/home_widget_service.dart';
import 'package:timeflow/features/home_widget/domain/models/home_widget_payload.dart';
import 'package:timeflow/features/home_widget/presentation/providers/home_widget_providers.dart';
import 'package:timeflow/features/tasks/domain/entities/task_entity.dart';
import 'package:timeflow/features/tasks/presentation/providers/task_providers.dart';

/// Fake implementation of IHomeWidgetService for unit & integration testing
class FakeHomeWidgetService implements IHomeWidgetService {
  int updateCallCount = 0;
  int clearCallCount = 0;
  HomeWidgetPayload? lastReceivedPayload;

  @override
  HomeWidgetPayload? get lastPayload => lastReceivedPayload;

  @override
  Future<bool> updateWidgets(HomeWidgetPayload payload) async {
    // Deduplication check
    if (lastReceivedPayload != null && lastReceivedPayload == payload) {
      return true;
    }
    updateCallCount++;
    lastReceivedPayload = payload;
    return true;
  }

  @override
  Future<bool> clearWidgets() async {
    clearCallCount++;
    lastReceivedPayload = null;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('vi', null);
  });

  group('HomeWidget Domain & Model Tests', () {
    test('1. HomeWidgetTaskSummary JSON serialization and deserialization', () {
      const summary = HomeWidgetTaskSummary(
        id: 'widget-task-1',
        title: 'Thiết kế Android Widget',
        description: 'Layout compact và expanded',
        timeRange: '08:00 - 09:30',
        priority: 'Khẩn cấp',
        isCompleted: false,
      );

      final json = summary.toJson();
      expect(json['id'], equals('widget-task-1'));
      expect(json['title'], equals('Thiết kế Android Widget'));
      expect(json['description'], equals('Layout compact và expanded'));
      expect(json['timeRange'], equals('08:00 - 09:30'));
      expect(json['priority'], equals('Khẩn cấp'));
      expect(json['isCompleted'], isFalse);

      final fromJson = HomeWidgetTaskSummary.fromJson(json);
      expect(fromJson, equals(summary));
      expect(fromJson.hashCode, equals(summary.hashCode));
    });

    test(
      '2. HomeWidgetTaskSummary handles null optional fields gracefully',
      () {
        const summary = HomeWidgetTaskSummary(
          id: 'widget-task-null',
          title: 'Công việc ngắn',
          priority: 'Trung bình',
        );

        final json = summary.toJson();
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('timeRange'), isFalse);

        final fromJson = HomeWidgetTaskSummary.fromJson(json);
        expect(fromJson.description, isNull);
        expect(fromJson.timeRange, isNull);
        expect(fromJson.title, equals('Công việc ngắn'));
        expect(fromJson.priority, equals('Trung bình'));
        expect(fromJson, equals(summary));
      },
    );

    test(
      '3. HomeWidgetPayload JSON serialization with both current and next tasks',
      () {
        const current = HomeWidgetTaskSummary(
          id: 'curr-1',
          title: 'Họp ban chỉ đạo',
          timeRange: '08:00 - 09:00',
          priority: 'Cao',
        );
        const next = HomeWidgetTaskSummary(
          id: 'next-1',
          title: 'Viết báo cáo kỹ thuật',
          timeRange: '09:00 - 10:30',
          priority: 'Trung bình',
        );

        final payload = HomeWidgetPayload(
          version: 1,
          currentTask: current,
          nextTask: next,
          totalTasksToday: 4,
          completedTasksToday: 2,
          headerDate: 'Thứ Bảy, 07/11/2026',
        );

        final json = payload.toJson();
        expect(json['version'], equals(1));
        expect(json['totalTasksToday'], equals(4));
        expect(json['completedTasksToday'], equals(2));
        expect(json['headerDate'], equals('Thứ Bảy, 07/11/2026'));
        expect(json['currentTask']['title'], equals('Họp ban chỉ đạo'));
        expect(json['nextTask']['title'], equals('Viết báo cáo kỹ thuật'));

        final fromJson = HomeWidgetPayload.fromJson(json);
        expect(fromJson.totalTasksToday, equals(4));
        expect(fromJson.completedTasksToday, equals(2));
        expect(fromJson.currentTask?.title, equals('Họp ban chỉ đạo'));
        expect(fromJson.nextTask?.title, equals('Viết báo cáo kỹ thuật'));
        expect(fromJson, equals(payload));
        expect(fromJson.hashCode, equals(payload.hashCode));
      },
    );

    test(
      '4. HomeWidgetPayload handles completely empty tasks and null fields',
      () {
        final payload = HomeWidgetPayload(headerDate: 'Chủ Nhật, 08/11/2026');

        expect(payload.hasCurrentTask, isFalse);
        expect(payload.hasNextTask, isFalse);
        expect(payload.hasAnyActiveTask, isFalse);
        expect(payload.totalTasksToday, equals(0));
        expect(payload.completedTasksToday, equals(0));
        expect(payload.progressPercent, equals(0));
        expect(payload.progressFractionText, equals('0/0'));

        final json = payload.toJson();
        final fromJson = HomeWidgetPayload.fromJson(json);
        expect(fromJson.hasCurrentTask, isFalse);
        expect(fromJson.hasNextTask, isFalse);
        expect(fromJson, equals(payload));
      },
    );

    test('5. Progress percent and fraction text calculation', () {
      final payload1 = HomeWidgetPayload(
        totalTasksToday: 5,
        completedTasksToday: 2,
        headerDate: 'Hôm nay',
      );
      expect(payload1.progressPercent, equals(40));
      expect(payload1.progressFractionText, equals('2/5'));

      final payload2 = HomeWidgetPayload(
        totalTasksToday: 3,
        completedTasksToday: 3,
        headerDate: 'Hôm nay',
      );
      expect(payload2.progressPercent, equals(100));
      expect(payload2.progressFractionText, equals('3/3'));

      final payload3 = HomeWidgetPayload(
        totalTasksToday: 0,
        completedTasksToday: 0,
        headerDate: 'Hôm nay',
      );
      expect(payload3.progressPercent, equals(0));
      expect(payload3.progressFractionText, equals('0/0'));
    });

    test('6. HomeWidgetPayload equality and deduplication logic', () {
      final payloadA = HomeWidgetPayload(
        totalTasksToday: 3,
        completedTasksToday: 1,
        headerDate: 'Thứ Bảy, 07/11/2026',
        currentTask: const HomeWidgetTaskSummary(
          id: '1',
          title: 'Task A',
          priority: 'Cao',
        ),
      );

      final payloadB = HomeWidgetPayload(
        totalTasksToday: 3,
        completedTasksToday: 1,
        headerDate: 'Thứ Bảy, 07/11/2026',
        currentTask: const HomeWidgetTaskSummary(
          id: '1',
          title: 'Task A',
          priority: 'Cao',
        ),
      );

      final payloadC = HomeWidgetPayload(
        totalTasksToday: 3,
        completedTasksToday: 2, // Changed completed count
        headerDate: 'Thứ Bảy, 07/11/2026',
        currentTask: const HomeWidgetTaskSummary(
          id: '1',
          title: 'Task A',
          priority: 'Cao',
        ),
      );

      expect(payloadA, equals(payloadB));
      expect(payloadA.hashCode, equals(payloadB.hashCode));
      expect(payloadA == payloadC, isFalse);
    });
  });

  group('Time-based Transition Logic (The 08:59 -> 09:00 Problem)', () {
    final baseDate = DateTime(2026, 11, 7);
    final task1 = TaskEntity(
      id: 'task-1',
      title: 'Công việc buổi sáng',
      startTime: DateTime(2026, 11, 7, 8, 0),
      endTime: DateTime(2026, 11, 7, 9, 0),
      priority: TaskPriority.high,
      createdAt: baseDate,
      updatedAt: baseDate,
    );

    final task2 = TaskEntity(
      id: 'task-2',
      title: 'Công việc tiếp theo',
      startTime: DateTime(2026, 11, 7, 9, 0),
      endTime: DateTime(2026, 11, 7, 10, 30),
      priority: TaskPriority.medium,
      createdAt: baseDate,
      updatedAt: baseDate,
    );

    final task3 = TaskEntity(
      id: 'task-3',
      title: 'Công việc chiều',
      startTime: DateTime(2026, 11, 7, 14, 0),
      endTime: DateTime(2026, 11, 7, 15, 0),
      priority: TaskPriority.low,
      createdAt: baseDate,
      updatedAt: baseDate,
    );

    test('7. At 08:59: task1 is Current, task2 is Next', () {
      final timeAt859 = DateTime(2026, 11, 7, 8, 59);
      final result = evaluateCurrentAndNextTask([
        task1,
        task2,
        task3,
      ], timeAt859);

      expect(result.currentTask, isNotNull);
      expect(result.currentTask!.id, equals('task-1'));
      expect(result.currentTask!.title, equals('Công việc buổi sáng'));

      expect(result.nextTask, isNotNull);
      expect(result.nextTask!.id, equals('task-2'));
      expect(result.nextTask!.title, equals('Công việc tiếp theo'));
    });

    test(
      '8. At 09:00: task1 has ended, task2 becomes Current, task3 becomes Next',
      () {
        final timeAt900 = DateTime(2026, 11, 7, 9, 0);
        final result = evaluateCurrentAndNextTask([
          task1,
          task2,
          task3,
        ], timeAt900);

        expect(result.currentTask, isNotNull);
        expect(result.currentTask!.id, equals('task-2'));
        expect(result.currentTask!.title, equals('Công việc tiếp theo'));

        expect(result.nextTask, isNotNull);
        expect(result.nextTask!.id, equals('task-3'));
        expect(result.nextTask!.title, equals('Công việc chiều'));
      },
    );

    test('9. At 10:31: task2 ended, no current task, task3 is Next', () {
      final timeAt1031 = DateTime(2026, 11, 7, 10, 31);
      final result = evaluateCurrentAndNextTask([
        task1,
        task2,
        task3,
      ], timeAt1031);

      expect(result.currentTask, isNull);
      expect(result.nextTask, isNotNull);
      expect(result.nextTask!.id, equals('task-3'));
    });

    test('10. At 15:01: all tasks ended, both current and next are null', () {
      final timeAt1501 = DateTime(2026, 11, 7, 15, 1);
      final result = evaluateCurrentAndNextTask([
        task1,
        task2,
        task3,
      ], timeAt1501);

      expect(result.currentTask, isNull);
      expect(result.nextTask, isNull);
    });

    test(
      '11. Dynamic boundary calculation calculateNextTransitionTime returns correct future moment',
      () {
        final timeAt830 = DateTime(2026, 11, 7, 8, 30);
        final nextBoundary = calculateNextTransitionTime([
          task1,
          task2,
          task3,
        ], timeAt830);

        // task1 ends at 09:00, task2 starts at 09:00 -> next transition is exactly 09:00
        expect(nextBoundary, equals(DateTime(2026, 11, 7, 9, 0)));

        final timeAt915 = DateTime(2026, 11, 7, 9, 15);
        final nextBoundary2 = calculateNextTransitionTime([
          task1,
          task2,
          task3,
        ], timeAt915);
        // task2 ends at 10:30 -> next transition is 10:30
        expect(nextBoundary2, equals(DateTime(2026, 11, 7, 10, 30)));

        final timeAt1600 = DateTime(2026, 11, 7, 16, 0);
        final nextBoundaryNone = calculateNextTransitionTime([
          task1,
          task2,
          task3,
        ], timeAt1600);
        expect(nextBoundaryNone, isNull);
      },
    );

    test(
      '12. Completed tasks are ignored in current and next task calculation',
      () {
        final completedTask1 = task1.copyWith(
          status: TaskStatus.completed,
          isCompleted: true,
        );
        final timeAt830 = DateTime(2026, 11, 7, 8, 30);

        final result = evaluateCurrentAndNextTask([
          completedTask1,
          task2,
          task3,
        ], timeAt830);
        // Because task1 is completed, it should not be current task
        expect(result.currentTask, isNull);
        // Next task is task2 (at 09:00)
        expect(result.nextTask?.id, equals('task-2'));
      },
    );

    test('13. Upcoming tasks are sorted chronologically ASC', () {
      final laterTask = TaskEntity(
        id: 'later',
        title: 'Họp 11h',
        startTime: DateTime(2026, 11, 7, 11, 0),
        endTime: DateTime(2026, 11, 7, 12, 0),
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      final earlierTask = TaskEntity(
        id: 'earlier',
        title: 'Họp 09h30',
        startTime: DateTime(2026, 11, 7, 9, 30),
        endTime: DateTime(2026, 11, 7, 10, 0),
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final timeAt900 = DateTime(2026, 11, 7, 9, 0);
      final result = evaluateCurrentAndNextTask([
        laterTask,
        earlierTask,
      ], timeAt900);

      expect(result.nextTask?.id, equals('earlier'));
      expect(result.nextTask?.title, equals('Họp 09h30'));
    });
  });

  group('HomeWidget Service & Bridge Tests', () {
    test('14. FakeHomeWidgetService deduplicates identical payloads', () async {
      final fakeService = FakeHomeWidgetService();
      final payload = HomeWidgetPayload(
        totalTasksToday: 3,
        completedTasksToday: 1,
        headerDate: 'Thứ Bảy, 07/11/2026',
      );

      final ok1 = await fakeService.updateWidgets(payload);
      expect(ok1, isTrue);
      expect(fakeService.updateCallCount, equals(1));

      // Same payload sent again -> deduplication skips update
      final ok2 = await fakeService.updateWidgets(payload);
      expect(ok2, isTrue);
      expect(fakeService.updateCallCount, equals(1));

      // Altered payload -> triggers update
      final alteredPayload = HomeWidgetPayload(
        totalTasksToday: 3,
        completedTasksToday: 2,
        headerDate: 'Thứ Bảy, 07/11/2026',
      );
      final ok3 = await fakeService.updateWidgets(alteredPayload);
      expect(ok3, isTrue);
      expect(fakeService.updateCallCount, equals(2));
    });

    test(
      '15. HomeWidgetServiceImpl safely handles non-Android platform (Windows/Web)',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        try {
          final realService = HomeWidgetServiceImpl();
          final payload = HomeWidgetPayload(
            totalTasksToday: 2,
            completedTasksToday: 1,
            headerDate: 'Thứ Bảy, 07/11/2026',
          );

          // On Windows desktop, platform guard should bypass native calls safely
          final result = await realService.updateWidgets(payload);
          expect(result, isTrue);
          expect(realService.lastPayload, equals(payload));

          final clearResult = await realService.clearWidgets();
          expect(clearResult, isTrue);
          expect(realService.lastPayload, isNull);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    test(
      '15b. HomeWidgetServiceImpl invokes home_widget method channel on Android',
      () async {
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('home_widget'), (
              MethodCall methodCall,
            ) async {
              calls.add(methodCall);
              return true;
            });

        final realService = HomeWidgetServiceImpl();
        final payload = HomeWidgetPayload(
          totalTasksToday: 2,
          completedTasksToday: 1,
          headerDate: 'Thứ Bảy, 07/11/2026',
          currentTask: const HomeWidgetTaskSummary(
            id: 'c1',
            title: 'Việc chính',
            priority: 'Cao',
          ),
        );

        final result = await realService.updateWidgets(payload);
        expect(result, isTrue);
        expect(calls.isNotEmpty, isTrue);

        // Verify saveWidgetData was called for keys
        final saveCalls = calls
            .where((c) => c.method == 'saveWidgetData')
            .toList();
        expect(saveCalls.any((c) => c.arguments['id'] == 'headerDate'), isTrue);
        expect(
          saveCalls.any((c) => c.arguments['id'] == 'currentTaskTitle'),
          isTrue,
        );

        // Verify updateWidget was called for both compact and expanded
        final updateCalls = calls
            .where((c) => c.method == 'updateWidget')
            .toList();
        expect(updateCalls.length, equals(2));

        // Cleanup
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
      },
    );

    test('16. mapTaskToWidgetSummary formats Vietnamese display names', () {
      final task = TaskEntity(
        id: 't-vn',
        title: 'Kiểm thử ứng dụng',
        startTime: DateTime(2026, 11, 7, 8, 30),
        endTime: DateTime(2026, 11, 7, 10, 0),
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 11, 7),
        updatedAt: DateTime(2026, 11, 7),
      );

      final summary = mapTaskToWidgetSummary(task);
      expect(summary.id, equals('t-vn'));
      expect(summary.title, equals('Kiểm thử ứng dụng'));
      expect(summary.timeRange, equals('08:30 - 10:00'));
      expect(summary.priority, equals('Khẩn cấp'));
      expect(summary.isCompleted, isFalse);
    });
  });

  group('Riverpod Provider Auto-Sync Integration Tests', () {
    test(
      '17. homeWidgetAutoSyncListenerProvider updates fakeService on task changes',
      () async {
        final fakeService = FakeHomeWidgetService();
        final now = DateTime.now();

        final taskA = TaskEntity(
          id: 'task-a',
          title: 'Task A',
          startTime: now.subtract(const Duration(minutes: 10)),
          endTime: now.add(const Duration(minutes: 30)),
          priority: TaskPriority.high,
          createdAt: now,
          updatedAt: now,
        );

        final container = ProviderContainer(
          overrides: [
            homeWidgetServiceProvider.overrideWithValue(fakeService),
            todayTasksStreamProvider.overrideWithValue(
              AsyncValue.data([taskA]),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Activate listener
        container.read(homeWidgetAutoSyncListenerProvider);

        // Trigger read to emit
        final payload = container.read(homeWidgetPayloadProvider);
        await fakeService.updateWidgets(payload);

        expect(fakeService.updateCallCount, equals(1));
        expect(fakeService.lastPayload?.hasCurrentTask, isTrue);
        expect(fakeService.lastPayload?.currentTask?.title, equals('Task A'));
      },
    );

    test(
      '18. Non-interference: lockscreen and home_widget have separate providers',
      () {
        final fakeHomeService = FakeHomeWidgetService();
        final container = ProviderContainer(
          overrides: [
            homeWidgetServiceProvider.overrideWithValue(fakeHomeService),
            todayTasksStreamProvider.overrideWithValue(
              const AsyncValue.data([]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final homePayload = container.read(homeWidgetPayloadProvider);
        expect(homePayload.totalTasksToday, equals(0));
        expect(homePayload.hasAnyActiveTask, isFalse);
      },
    );
  });

  group('Sprint 6.2 Functional Verification & Edge Cases', () {
    final baseDate = DateTime(2026, 11, 9, 10, 0); // 10:00

    test('19. Empty State: No tasks produces clean empty payload', () {
      final evaluated = evaluateCurrentAndNextTask([], baseDate);
      expect(evaluated.currentTask, isNull);
      expect(evaluated.nextTask, isNull);

      final payload = HomeWidgetPayload(
        headerDate: 'Thứ Hai, 09/11',
        totalTasksToday: 0,
        completedTasksToday: 0,
        currentTask: null,
        nextTask: null,
      );

      expect(payload.hasCurrentTask, isFalse);
      expect(payload.hasNextTask, isFalse);
      expect(payload.hasAnyActiveTask, isFalse);
      expect(payload.progressFractionText, equals('0/0'));
      expect(payload.progressPercent, equals(0));
    });

    test('20. Single ongoing task identified as Current Task', () {
      final current = TaskEntity(
        id: 'task-curr',
        title: 'Test Widget Current',
        startTime: DateTime(2026, 11, 9, 9, 30),
        endTime: DateTime(2026, 11, 9, 10, 30),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([current], baseDate);
      expect(evaluated.currentTask, isNotNull);
      expect(evaluated.currentTask?.title, equals('Test Widget Current'));
      expect(evaluated.currentTask?.priority, equals(TaskPriority.high));
      expect(evaluated.nextTask, isNull);
    });

    test('21. Current Task + Next Task non-overlapping identified accurately', () {
      final taskA = TaskEntity(
        id: 'task-a',
        title: 'Task A (Current)',
        startTime: DateTime(2026, 11, 9, 9, 0),
        endTime: DateTime(2026, 11, 9, 10, 30),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final taskB = TaskEntity(
        id: 'task-b',
        title: 'Task B (Next)',
        startTime: DateTime(2026, 11, 9, 11, 0),
        endTime: DateTime(2026, 11, 9, 12, 0),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([taskB, taskA], baseDate);
      expect(evaluated.currentTask?.id, equals('task-a'));
      expect(evaluated.nextTask?.id, equals('task-b'));
    });

    test('22. Completed task is excluded; widget transfers to next task', () {
      final taskA = TaskEntity(
        id: 'task-a',
        title: 'Task A (Completed)',
        startTime: DateTime(2026, 11, 9, 9, 0),
        endTime: DateTime(2026, 11, 9, 10, 30),
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        isCompleted: true,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final taskB = TaskEntity(
        id: 'task-b',
        title: 'Task B (Next)',
        startTime: DateTime(2026, 11, 9, 10, 30),
        endTime: DateTime(2026, 11, 9, 11, 30),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([taskA, taskB], baseDate);
      expect(evaluated.currentTask, isNull);
      expect(evaluated.nextTask?.id, equals('task-b'));
    });

    test('23. Multiple tasks sorted chronologically by startTime ASC', () {
      final t1 = TaskEntity(
        id: 't1',
        title: 'Task 1',
        startTime: DateTime(2026, 11, 9, 14, 0),
        endTime: DateTime(2026, 11, 9, 15, 0),
        priority: TaskPriority.low,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final t2 = TaskEntity(
        id: 't2',
        title: 'Task 2',
        startTime: DateTime(2026, 11, 9, 11, 0),
        endTime: DateTime(2026, 11, 9, 12, 0),
        priority: TaskPriority.medium,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final t3 = TaskEntity(
        id: 't3',
        title: 'Task 3',
        startTime: DateTime(2026, 11, 9, 16, 0),
        endTime: DateTime(2026, 11, 9, 17, 0),
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([t3, t1, t2], baseDate);
      expect(evaluated.currentTask, isNull);
      expect(evaluated.nextTask?.id, equals('t2')); // Earliest upcoming is t2 (11:00)
    });

    test('24. Overlapping tasks: Highest priority task is chosen as Current Task', () {
      final normalTask = TaskEntity(
        id: 'normal',
        title: 'Reading Documentation',
        startTime: DateTime(2026, 11, 9, 9, 0),
        endTime: DateTime(2026, 11, 9, 11, 0),
        priority: TaskPriority.low,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final urgentTask = TaskEntity(
        id: 'urgent',
        title: 'Emergency Server Outage',
        startTime: DateTime(2026, 11, 9, 9, 45),
        endTime: DateTime(2026, 11, 9, 10, 30),
        priority: TaskPriority.urgent,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      // Regardless of insertion order, urgent task wins at 10:00
      final evaluated1 = evaluateCurrentAndNextTask([normalTask, urgentTask], baseDate);
      expect(evaluated1.currentTask?.id, equals('urgent'));

      final evaluated2 = evaluateCurrentAndNextTask([urgentTask, normalTask], baseDate);
      expect(evaluated2.currentTask?.id, equals('urgent'));
    });

    test('25. Overlapping tasks with same priority: Earlier startTime chosen', () {
      final task1 = TaskEntity(
        id: 'first',
        title: 'First Meeting',
        startTime: DateTime(2026, 11, 9, 9, 30),
        endTime: DateTime(2026, 11, 9, 10, 30),
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final task2 = TaskEntity(
        id: 'second',
        title: 'Second Meeting',
        startTime: DateTime(2026, 11, 9, 9, 45),
        endTime: DateTime(2026, 11, 9, 10, 45),
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([task2, task1], baseDate);
      expect(evaluated.currentTask?.id, equals('first'));
    });

    test('26. Boundary: Exact start time is considered started (inclusive)', () {
      final task = TaskEntity(
        id: 'exact-start',
        title: 'Sharp Start',
        startTime: baseDate, // 10:00:00
        endTime: DateTime(2026, 11, 9, 11, 0),
        priority: TaskPriority.medium,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([task], baseDate);
      expect(evaluated.currentTask?.id, equals('exact-start'));
      expect(evaluated.nextTask, isNull);
    });

    test('27. Boundary: Exact end time is considered finished (exclusive)', () {
      final task = TaskEntity(
        id: 'exact-end',
        title: 'Sharp End',
        startTime: DateTime(2026, 11, 9, 9, 0),
        endTime: baseDate, // 10:00:00
        priority: TaskPriority.medium,
        createdAt: DateTime(2026, 11, 9),
        updatedAt: DateTime(2026, 11, 9),
      );

      final evaluated = evaluateCurrentAndNextTask([task], baseDate);
      expect(evaluated.currentTask, isNull);
    });

    test('28. Midnight transition: yesterday tasks are excluded from today payload', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final yesterdayTask = TaskEntity(
        id: 'yesterday-task',
        title: 'Yesterday Task',
        startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 22, 0),
        endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 0),
        priority: TaskPriority.high,
        isCompleted: true,
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      final todayTask = TaskEntity(
        id: 'today-task',
        title: 'Today Morning Standup',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 30),
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          todayTasksStreamProvider.overrideWithValue(
            AsyncValue.data([yesterdayTask, todayTask]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final payload = container.read(homeWidgetPayloadProvider);
      // Yesterday's task was excluded by clock day filter
      expect(payload.totalTasksToday, equals(1));
      expect(payload.completedTasksToday, equals(0));
      expect(payload.progressFractionText, equals('0/1'));
    });

    test('29. CRUD Simulation: State progression reflects in widget payload', () async {
      final fakeService = FakeHomeWidgetService();
      final now = DateTime(2026, 11, 9, 10, 0);

      // Create
      final task1 = TaskEntity(
        id: 'crud-1',
        title: 'Initial Title',
        startTime: DateTime(2026, 11, 9, 9, 30),
        endTime: DateTime(2026, 11, 9, 10, 30),
        priority: TaskPriority.low,
        createdAt: now,
        updatedAt: now,
      );

      final evalCreate = evaluateCurrentAndNextTask([task1], now);
      final payloadCreate = HomeWidgetPayload(
        headerDate: 'Thứ Hai, 09/11',
        totalTasksToday: 1,
        completedTasksToday: 0,
        currentTask: mapTaskToWidgetSummary(evalCreate.currentTask!),
      );
      await fakeService.updateWidgets(payloadCreate);
      expect(fakeService.lastPayload?.currentTask?.title, equals('Initial Title'));
      expect(fakeService.lastPayload?.currentTask?.priority, equals('Thấp'));

      // Update
      final task1Updated = task1.copyWith(
        title: 'Updated Title',
        priority: TaskPriority.urgent,
      );
      final evalUpdate = evaluateCurrentAndNextTask([task1Updated], now);
      final payloadUpdate = HomeWidgetPayload(
        headerDate: 'Thứ Hai, 09/11',
        totalTasksToday: 1,
        completedTasksToday: 0,
        currentTask: mapTaskToWidgetSummary(evalUpdate.currentTask!),
      );
      await fakeService.updateWidgets(payloadUpdate);
      expect(fakeService.lastPayload?.currentTask?.title, equals('Updated Title'));
      expect(fakeService.lastPayload?.currentTask?.priority, equals('Khẩn cấp'));

      // Complete
      final task1Completed = task1Updated.copyWith(
        status: TaskStatus.completed,
        isCompleted: true,
      );
      final evalComplete = evaluateCurrentAndNextTask([task1Completed], now);
      final payloadComplete = HomeWidgetPayload(
        headerDate: 'Thứ Hai, 09/11',
        totalTasksToday: 1,
        completedTasksToday: 1,
        currentTask: evalComplete.currentTask != null
            ? mapTaskToWidgetSummary(evalComplete.currentTask!)
            : null,
      );
      await fakeService.updateWidgets(payloadComplete);
      expect(fakeService.lastPayload?.hasCurrentTask, isFalse);
      expect(fakeService.lastPayload?.progressFractionText, equals('1/1'));
      expect(fakeService.lastPayload?.progressPercent, equals(100));

      // Delete
      await fakeService.clearWidgets();
      expect(fakeService.lastPayload, isNull);
    });
  });
}
