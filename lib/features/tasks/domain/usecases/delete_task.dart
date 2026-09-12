import '../../../../data/repositories/task_repository.dart';

class DeleteTask {
  final ITaskRepository repository;

  DeleteTask(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID công việc không hợp lệ.');
    }
    await repository.deleteTask(id);
  }
}
