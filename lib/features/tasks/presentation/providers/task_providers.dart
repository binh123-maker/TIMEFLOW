import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/daos/task_dao.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';

/// Database Instance Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Task DAO Provider
final taskDaoProvider = Provider<TaskDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.taskDao;
});

/// Task Repository Provider
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final dao = ref.watch(taskDaoProvider);
  return TaskRepositoryImpl(dao);
});

/// Use Case Providers
final createTaskUseCaseProvider = Provider<CreateTask>((ref) {
  return CreateTask(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.watch(taskRepositoryProvider));
});

final toggleTaskCompletionUseCaseProvider = Provider<ToggleTaskCompletion>((
  ref,
) {
  return ToggleTaskCompletion(ref.watch(taskRepositoryProvider));
});

final getTasksUseCaseProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.watch(taskRepositoryProvider));
});

/// Reactive Stream Provider for All Tasks
final allTasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  final getTasks = ref.watch(getTasksUseCaseProvider);
  return getTasks.watchAll();
});

/// Derived Stream Provider for Today's Tasks
final todayTasksStreamProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final allTasksAsync = ref.watch(allTasksStreamProvider);
  final now = DateTime.now();

  return allTasksAsync.whenData((tasks) {
    return tasks.where((task) {
      if (task.dueDate != null) {
        return _isSameDay(task.dueDate!, now);
      }
      if (task.startTime != null) {
        return _isSameDay(task.startTime!, now);
      }
      return true; // Tasks without specific date are included in Today view by default
    }).toList();
  });
});

/// Derived Stream Provider for Current Active Task
final currentTaskStreamProvider = Provider<AsyncValue<TaskEntity?>>((ref) {
  final todayTasksAsync = ref.watch(todayTasksStreamProvider);
  final now = DateTime.now();

  return todayTasksAsync.whenData((tasks) {
    try {
      return tasks.firstWhere((t) {
        if (t.isCompleted) return false;
        if (t.startTime != null && t.endTime != null) {
          return (t.startTime!.isBefore(now) ||
                  t.startTime!.isAtSameMomentAs(now)) &&
              t.endTime!.isAfter(now);
        }
        return false;
      });
    } catch (_) {
      return null;
    }
  });
});

/// Derived Stream Provider for Next Upcoming Task
final nextTaskStreamProvider = Provider<AsyncValue<TaskEntity?>>((ref) {
  final todayTasksAsync = ref.watch(todayTasksStreamProvider);
  final now = DateTime.now();

  return todayTasksAsync.whenData((tasks) {
    final upcoming = tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.startTime != null) {
        return t.startTime!.isAfter(now);
      }
      return true;
    }).toList();

    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) {
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    return upcoming.first;
  });
});

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
