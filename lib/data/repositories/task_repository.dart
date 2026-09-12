import '../../features/tasks/domain/entities/task_entity.dart';

/// Repository Contract for Tasks Data Access
abstract class ITaskRepository {
  /// Stream of all tasks ordered by time
  Stream<List<TaskEntity>> watchAllTasks();

  /// Snapshot list of all tasks
  Future<List<TaskEntity>> getAllTasks();

  /// Get task by ID
  Future<TaskEntity?> getTaskById(String id);

  /// Create new task
  Future<void> createTask(TaskEntity task);

  /// Update existing task
  Future<void> updateTask(TaskEntity task);

  /// Delete task by ID
  Future<void> deleteTask(String id);

  /// Toggle task completion state
  Future<void> toggleTaskCompletion(String id);
}
