import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/task_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Reactive stream of all tasks ordered by startTime/dueDate
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)..orderBy([
          (t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  /// Get all tasks as a snapshot List
  Future<List<Task>> getAllTasks() {
    return (select(tasks)..orderBy([
          (t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Get single task by ID
  Future<Task?> getTaskById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new task
  Future<int> insertTask(TasksCompanion entry) {
    return into(tasks).insert(entry, mode: InsertMode.insertOrReplace);
  }

  /// Update an existing task
  Future<bool> updateTask(TasksCompanion entry) {
    return update(tasks).replace(entry);
  }

  /// Delete task by ID
  Future<int> deleteTask(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }
}
