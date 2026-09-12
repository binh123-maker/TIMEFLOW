import '../../../../data/repositories/task_repository.dart';
import '../entities/task_entity.dart';

class UpdateTask {
  final ITaskRepository repository;

  UpdateTask(this.repository);

  Future<void> call(TaskEntity task) async {
    final trimmedTitle = task.title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Tiêu đề công việc không được để trống.');
    }

    if (task.startTime != null &&
        task.endTime != null &&
        !task.startTime!.isBefore(task.endTime!)) {
      throw ArgumentError('Thời gian bắt đầu phải trước thời gian kết thúc.');
    }

    final updatedTask = task.copyWith(
      title: trimmedTitle,
      description: task.description?.trim().isEmpty == true
          ? null
          : task.description?.trim(),
      updatedAt: DateTime.now(),
    );

    await repository.updateTask(updatedTask);
  }
}
