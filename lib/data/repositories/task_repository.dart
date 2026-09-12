import '../models/task_model.dart';
import '../../core/constants/app_colors.dart';

/// Repository interface for Tasks
abstract class ITaskRepository {
  Future<List<TaskModel>> getTodayTasks();
  Future<TaskModel?> getCurrentTask();
  Future<TaskModel?> getNextTask();
}

/// Initial implementation supplying realistic sample schedule items for Today screen
class MockTaskRepository implements ITaskRepository {
  @override
  Future<List<TaskModel>> getTodayTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      TaskModel(
        id: '1',
        title: 'Lập kế hoạch công việc tuần mới',
        description: 'Xác định mục tiêu chính và sắp xếp thứ tự ưu tiên các dự án.',
        startTime: today.add(const Duration(hours: 8, minutes: 0)),
        endTime: today.add(const Duration(hours: 8, minutes: 45)),
        category: 'Công việc',
        categoryColor: AppColors.primary,
        status: TaskStatus.completed,
        priority: TaskPriority.high,
      ),
      TaskModel(
        id: '2',
        title: 'Khởi tạo cấu trúc dự án TIMEFLOW',
        description: 'Thiết lập Flutter clean architecture, GoRouter, Riverpod và Material 3 theme.',
        startTime: today.add(const Duration(hours: 9, minutes: 0)),
        endTime: today.add(const Duration(hours: 11, minutes: 30)),
        category: 'Phát triển',
        categoryColor: AppColors.secondary,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
      ),
      TaskModel(
        id: '3',
        title: 'Họp Review Thiết kế UI/UX',
        description: 'Thảo luận về giao diện Responsive trên Mobile và Desktop Windows.',
        startTime: today.add(const Duration(hours: 14, minutes: 0)),
        endTime: today.add(const Duration(hours: 15, minutes: 0)),
        category: 'Họp hành',
        categoryColor: AppColors.purple,
        status: TaskStatus.upcoming,
        priority: TaskPriority.medium,
      ),
      TaskModel(
        id: '4',
        title: 'Kiểm thử Build Android & Windows',
        description: 'Chạy flutter analyze và kiểm tra khả năng build đa nền tảng.',
        startTime: today.add(const Duration(hours: 16, minutes: 0)),
        endTime: today.add(const Duration(hours: 17, minutes: 30)),
        category: 'Kiểm thử',
        categoryColor: AppColors.success,
        status: TaskStatus.upcoming,
        priority: TaskPriority.medium,
      ),
    ];
  }

  @override
  Future<TaskModel?> getCurrentTask() async {
    final tasks = await getTodayTasks();
    try {
      return tasks.firstWhere((task) => task.status == TaskStatus.inProgress);
    } catch (_) {
      return tasks.isNotEmpty ? tasks.first : null;
    }
  }

  @override
  Future<TaskModel?> getNextTask() async {
    final tasks = await getTodayTasks();
    try {
      return tasks.firstWhere((task) => task.status == TaskStatus.upcoming);
    } catch (_) {
      return null;
    }
  }
}
