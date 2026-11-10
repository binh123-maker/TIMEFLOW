import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'package:timeflow/data/database/app_database.dart';
import 'package:timeflow/data/repositories/task_repository_impl.dart';
import 'package:timeflow/features/tasks/domain/entities/task_entity.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl repository;

  setUp(() {
    // In-memory database for testing
    db = AppDatabase(NativeDatabase.memory());
    repository = TaskRepositoryImpl(db.taskDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift SQLite Database & Repository Integration Tests', () {
    test('Insert task and read from stream', () async {
      final now = DateTime.now();
      final task = TaskEntity(
        id: 'test-id-1',
        title: 'Thực hành Drift SQLite',
        description: 'Test case tự động cho Phase 2',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTask(task);

      final tasks = await repository.getAllTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Thực hành Drift SQLite'));
      expect(tasks.first.priority, equals(TaskPriority.high));
    });

    test('Update task title and status', () async {
      final now = DateTime.now();
      final task = TaskEntity(
        id: 'test-id-2',
        title: 'Học Flutter Clean Architecture',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTask(task);

      final updatedTask = task.copyWith(
        title: 'Học Flutter & Drift SQLite nâng cao',
        status: TaskStatus.inProgress,
      );

      await repository.updateTask(updatedTask);

      final readTask = await repository.getTaskById('test-id-2');
      expect(readTask, isNotNull);
      expect(readTask?.title, equals('Học Flutter & Drift SQLite nâng cao'));
      expect(readTask?.status, equals(TaskStatus.inProgress));
    });

    test('Toggle task completion maintains data integrity', () async {
      final now = DateTime.now();
      final task = TaskEntity(
        id: 'test-id-3',
        title: 'Viết unit test cho Task completion',
        isCompleted: false,
        status: TaskStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTask(task);

      // Toggle to Completed
      await repository.toggleTaskCompletion('test-id-3');
      var readTask = await repository.getTaskById('test-id-3');
      expect(readTask?.isCompleted, isTrue);
      expect(readTask?.status, equals(TaskStatus.completed));

      // Toggle back to Uncompleted
      await repository.toggleTaskCompletion('test-id-3');
      readTask = await repository.getTaskById('test-id-3');
      expect(readTask?.isCompleted, isFalse);
      expect(readTask?.status, equals(TaskStatus.pending));
    });

    test('Delete task removes item from SQLite database', () async {
      final now = DateTime.now();
      final task = TaskEntity(
        id: 'test-id-4',
        title: 'Công việc sẽ bị xóa',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTask(task);
      expect((await repository.getAllTasks()).length, equals(1));

      await repository.deleteTask('test-id-4');
      expect((await repository.getAllTasks()).length, equals(0));
    });

    test(
      'Drift v2 schema stores and reads reminderEnabled and reminderMinutesBefore',
      () async {
        final now = DateTime.now();
        final taskWithReminder = TaskEntity(
          id: 'migration-test-1',
          title: 'Migration Task With Reminder',
          reminderEnabled: true,
          reminderMinutesBefore: 15,
          createdAt: now,
          updatedAt: now,
        );

        await repository.createTask(taskWithReminder);

        final loaded = await repository.getTaskById('migration-test-1');
        expect(loaded, isNotNull);
        expect(loaded?.reminderEnabled, isTrue);
        expect(loaded?.reminderMinutesBefore, equals(15));
      },
    );

    test(
      'Drift v1 to v2 migration preserves existing tasks and populates defaults',
      () async {
        // 1. Create raw in-memory SQLite database simulating schema v1
        final rawDb = sqlite3.openInMemory();

        // Create v1 table structure and user_version = 1
        rawDb.execute(
          'CREATE TABLE tasks ('
          'id TEXT NOT NULL PRIMARY KEY, '
          'title TEXT NOT NULL, '
          'description TEXT, '
          'status TEXT NOT NULL, '
          'priority TEXT NOT NULL, '
          'due_date INTEGER, '
          'start_time INTEGER, '
          'end_time INTEGER, '
          'is_completed INTEGER NOT NULL DEFAULT 0, '
          'created_at INTEGER NOT NULL, '
          'updated_at INTEGER NOT NULL'
          ');',
        );
        rawDb.execute('PRAGMA user_version = 1;');

        // Insert pre-existing v1 tasks
        final timestamp = DateTime(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
        rawDb.execute(
          "INSERT INTO tasks (id, title, description, status, priority, is_completed, created_at, updated_at) "
          "VALUES ('v1-task-1', 'Pre-existing Task 1', 'Created in v1', 'pending', 'high', 0, $timestamp, $timestamp);",
        );
        rawDb.execute(
          "INSERT INTO tasks (id, title, description, status, priority, is_completed, created_at, updated_at) "
          "VALUES ('v1-task-2', 'Pre-existing Task 2', 'Created in v1', 'completed', 'medium', 1, $timestamp, $timestamp);",
        );

        // 2. Open with AppDatabase (schemaVersion 2) to trigger migration.onUpgrade(1, 2)
        final migratedDb = AppDatabase(NativeDatabase.opened(rawDb));
        final migratedRepo = TaskRepositoryImpl(migratedDb.taskDao);

        final tasks = await migratedRepo.getAllTasks();
        expect(tasks.length, equals(2));

        final task1 = tasks.firstWhere((t) => t.id == 'v1-task-1');
        expect(task1.title, equals('Pre-existing Task 1'));
        expect(task1.description, equals('Created in v1'));
        expect(task1.priority, equals(TaskPriority.high));
        expect(task1.isCompleted, isFalse);
        expect(task1.reminderEnabled, isFalse);
        expect(task1.reminderMinutesBefore, equals(0));

        final task2 = tasks.firstWhere((t) => t.id == 'v1-task-2');
        expect(task2.title, equals('Pre-existing Task 2'));
        expect(task2.isCompleted, isTrue);
        expect(task2.reminderEnabled, isFalse);
        expect(task2.reminderMinutesBefore, equals(0));

        await migratedDb.close();
      },
    );
  });
}
