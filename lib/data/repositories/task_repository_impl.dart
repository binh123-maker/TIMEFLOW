import 'package:drift/drift.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import '../database/app_database.dart';
import '../database/daos/task_dao.dart';
import 'task_repository.dart';

/// Implementation of ITaskRepository bridging Drift DAO and Domain Layer
class TaskRepositoryImpl implements ITaskRepository {
  final TaskDao _taskDao;

  TaskRepositoryImpl(this._taskDao);

  @override
  Stream<List<TaskEntity>> watchAllTasks() {
    return _taskDao.watchAllTasks().map(
      (rows) => rows.map(_mapToEntity).toList(),
    );
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final rows = await _taskDao.getAllTasks();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final row = await _taskDao.getTaskById(id);
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final companion = _mapToCompanion(task);
    await _taskDao.insertTask(companion);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final companion = _mapToCompanion(task);
    await _taskDao.updateTask(companion);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _taskDao.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task == null) return;

    final newIsCompleted = !task.isCompleted;
    final newStatus = newIsCompleted
        ? TaskStatus.completed
        : TaskStatus.pending;
    final updatedTask = task.copyWith(
      isCompleted: newIsCompleted,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await updateTask(updatedTask);
  }

  TaskEntity _mapToEntity(Task row) {
    return TaskEntity(
      id: row.id,
      title: row.title,
      description: row.description,
      status: TaskStatus.fromString(row.status),
      priority: TaskPriority.fromString(row.priority),
      dueDate: row.dueDate,
      startTime: row.startTime,
      endTime: row.endTime,
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TasksCompanion _mapToCompanion(TaskEntity entity) {
    return TasksCompanion(
      id: Value(entity.id),
      title: Value(entity.title),
      description: Value(entity.description),
      status: Value(entity.status.name),
      priority: Value(entity.priority.name),
      dueDate: Value(entity.dueDate),
      startTime: Value(entity.startTime),
      endTime: Value(entity.endTime),
      isCompleted: Value(entity.isCompleted),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
