import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/database/app_database.dart';
import 'package:timeflow/data/repositories/task_repository_impl.dart';
import 'package:timeflow/features/tasks/domain/usecases/create_task.dart';
import 'package:timeflow/features/tasks/domain/usecases/update_task.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl repository;
  late CreateTask createTask;
  late UpdateTask updateTask;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = TaskRepositoryImpl(db.taskDao);
    createTask = CreateTask(repository);
    updateTask = UpdateTask(repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('Task Use Case Validation Tests', () {
    test('CreateTask throws ArgumentError when title is empty', () async {
      expect(() => createTask(title: ''), throwsA(isA<ArgumentError>()));
    });

    test(
      'CreateTask throws ArgumentError when title is only whitespace',
      () async {
        expect(
          () => createTask(title: '    \n\t  '),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'CreateTask throws ArgumentError when startTime is after endTime',
      () async {
        final now = DateTime.now();
        final startTime = now.add(const Duration(hours: 2));
        final endTime = now.add(const Duration(hours: 1));

        expect(
          () => createTask(
            title: 'Họp ngược thời gian',
            startTime: startTime,
            endTime: endTime,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('CreateTask succeeds with valid title and valid time range', () async {
      final now = DateTime.now();
      final startTime = now.add(const Duration(hours: 1));
      final endTime = now.add(const Duration(hours: 2));

      await createTask(
        title: 'Họp dự án TIMEFLOW',
        startTime: startTime,
        endTime: endTime,
      );

      final tasks = await repository.getAllTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Họp dự án TIMEFLOW'));
    });

    test(
      'UpdateTask updates title and validates non-empty constraint',
      () async {
        await createTask(title: 'Tác vụ ban đầu');
        final tasks = await repository.getAllTasks();
        final created = tasks.first;

        expect(
          () => updateTask(created.copyWith(title: '   ')),
          throwsA(isA<ArgumentError>()),
        );

        final updated = created.copyWith(title: 'Tác vụ đã sửa');
        await updateTask(updated);

        final read = await repository.getTaskById(created.id);
        expect(read?.title, equals('Tác vụ đã sửa'));
      },
    );
  });
}
