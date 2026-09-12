import '../../../../data/repositories/task_repository.dart';

class ToggleTaskCompletion {
  final ITaskRepository repository;

  ToggleTaskCompletion(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) return;
    await repository.toggleTaskCompletion(id);
  }
}
