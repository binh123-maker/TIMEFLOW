import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/core/utils/date_formatter.dart';
import 'package:timeflow/data/database/app_database.dart';
import 'package:timeflow/data/repositories/task_repository_impl.dart';
import 'package:timeflow/features/tasks/domain/entities/task_entity.dart';
import 'package:timeflow/features/tasks/domain/usecases/create_task.dart';
import 'package:timeflow/features/tasks/domain/usecases/toggle_task_completion.dart';

void main() {
  group('Calendar & Date Helper Unit Tests', () {
    test(
      'isSameDay returns true for same day with different time components',
      () {
        final dt1 = DateTime(2026, 9, 15, 0, 0, 0);
        final dt2 = DateTime(2026, 9, 15, 23, 59, 59);

        expect(DateFormatter.isSameDay(dt1, dt2), isTrue);
      },
    );

    test('isSameDay returns false for different dates', () {
      final dt1 = DateTime(2026, 9, 15, 23, 59, 59);
      final dt2 = DateTime(2026, 9, 16, 0, 0, 0);

      expect(DateFormatter.isSameDay(dt1, dt2), isFalse);
    });

    test('isSameDay returns false when either date is null', () {
      final dt = DateTime(2026, 9, 15);

      expect(DateFormatter.isSameDay(null, dt), isFalse);
      expect(DateFormatter.isSameDay(dt, null), isFalse);
      expect(DateFormatter.isSameDay(null, null), isFalse);
    });

    test('Task sorting places timed tasks ASC before untimed tasks', () {
      final now = DateTime.now();
      final day = DateTime(2026, 9, 15);

      final taskA = TaskEntity(
        id: '1',
        title: 'Task A (14:00)',
        dueDate: day,
        startTime: DateTime(2026, 9, 15, 14, 0),
        createdAt: now.add(const Duration(seconds: 1)),
        updatedAt: now,
      );
      final taskB = TaskEntity(
        id: '2',
        title: 'Task B (Untimed)',
        dueDate: day,
        startTime: null,
        createdAt: now.add(const Duration(seconds: 2)),
        updatedAt: now,
      );
      final taskC = TaskEntity(
        id: '3',
        title: 'Task C (08:00)',
        dueDate: day,
        startTime: DateTime(2026, 9, 15, 8, 0),
        createdAt: now.add(const Duration(seconds: 3)),
        updatedAt: now,
      );

      final list = [taskA, taskB, taskC];

      list.sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          final cmp = a.startTime!.compareTo(b.startTime!);
          if (cmp != 0) return cmp;
          return a.createdAt.compareTo(b.createdAt);
        }
        if (a.startTime != null && b.startTime == null) return -1;
        if (a.startTime == null && b.startTime != null) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });

      expect(list.map((t) => t.id).toList(), equals(['3', '1', '2']));
    });

    test('Task dot indicator levels cap at 3 maximum', () {
      int calculateDotLevel(int count) {
        if (count == 0) return 0;
        return count > 3 ? 3 : count;
      }

      expect(calculateDotLevel(0), equals(0));
      expect(calculateDotLevel(1), equals(1));
      expect(calculateDotLevel(2), equals(2));
      expect(calculateDotLevel(5), equals(3));
      expect(calculateDotLevel(100), equals(3));
    });
  });

  group('Calendar & SQLite Integration Tests', () {
    late AppDatabase db;
    late TaskRepositoryImpl repository;
    late CreateTask createTask;
    late ToggleTaskCompletion toggleTaskCompletion;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = TaskRepositoryImpl(db.taskDao);
      createTask = CreateTask(repository);
      toggleTaskCompletion = ToggleTaskCompletion(repository);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Create task with specific dueDate appears in SQLite for that day',
      () async {
        final selectedDate = DateTime(2026, 9, 15);

        await createTask(
          title: 'Học Spring Boot',
          dueDate: selectedDate,
          startTime: DateTime(2026, 9, 15, 8, 0),
        );

        final all = await repository.getAllTasks();
        expect(all.length, equals(1));

        final matched = all
            .where((t) => DateFormatter.isSameDay(t.dueDate, selectedDate))
            .toList();
        expect(matched.length, equals(1));
        expect(matched.first.title, equals('Học Spring Boot'));
      },
    );

    test('Updating task dueDate moves task to new date', () async {
      final date1 = DateTime(2026, 9, 15);
      final date2 = DateTime(2026, 9, 16);

      await createTask(title: 'Chuyển lịch', dueDate: date1);

      final all = await repository.getAllTasks();
      final task = all.first;

      final updated = task.copyWith(dueDate: date2);
      await repository.updateTask(updated);

      final newAll = await repository.getAllTasks();
      final day1Tasks = newAll
          .where((t) => DateFormatter.isSameDay(t.dueDate, date1))
          .toList();
      final day2Tasks = newAll
          .where((t) => DateFormatter.isSameDay(t.dueDate, date2))
          .toList();

      expect(day1Tasks.isEmpty, isTrue);
      expect(day2Tasks.length, equals(1));
    });

    test('Toggle completion synchronizes task status in SQLite', () async {
      await createTask(title: 'Test completion toggle');

      final all = await repository.getAllTasks();
      final task = all.first;

      await toggleTaskCompletion(task.id);

      final read = await repository.getTaskById(task.id);
      expect(read?.isCompleted, isTrue);
      expect(read?.status, equals(TaskStatus.completed));
    });
  });
}
