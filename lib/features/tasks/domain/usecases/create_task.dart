import 'package:uuid/uuid.dart';
import '../../../../data/repositories/task_repository.dart';
import '../entities/task_entity.dart';

class CreateTask {
  final ITaskRepository repository;
  final Uuid _uuid = const Uuid();

  CreateTask(this.repository);

  Future<void> call({
    required String title,
    String? description,
    TaskStatus status = TaskStatus.pending,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    DateTime? startTime,
    DateTime? endTime,
    bool isCompleted = false,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Tiêu đề công việc không được để trống.');
    }

    if (startTime != null && endTime != null && !startTime.isBefore(endTime)) {
      throw ArgumentError('Thời gian bắt đầu phải trước thời gian kết thúc.');
    }

    final now = DateTime.now();
    final task = TaskEntity(
      id: _uuid.v4(),
      title: trimmedTitle,
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      status: isCompleted ? TaskStatus.completed : status,
      priority: priority,
      dueDate: dueDate,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
    );

    await repository.createTask(task);
  }
}
