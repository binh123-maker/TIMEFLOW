import '../../../../data/repositories/task_repository.dart';
import '../entities/task_entity.dart';

class GetTasks {
  final ITaskRepository repository;

  GetTasks(this.repository);

  Stream<List<TaskEntity>> watchAll() {
    return repository.watchAllTasks();
  }

  Future<List<TaskEntity>> getAll() {
    return repository.getAllTasks();
  }
}
