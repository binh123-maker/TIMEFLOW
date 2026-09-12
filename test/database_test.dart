import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
