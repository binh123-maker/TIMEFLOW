import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  return MockTaskRepository();
});

final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getTodayTasks();
});

final currentTaskProvider = FutureProvider<TaskModel?>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getCurrentTask();
});

final nextTaskProvider = FutureProvider<TaskModel?>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getNextTask();
});

/// Stream provider for live digital clock update (remains accurate to second)
final liveClockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
