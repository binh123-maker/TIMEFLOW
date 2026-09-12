import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_form_dialog.dart';
import '../providers/calendar_providers.dart';

class CalendarTaskList extends ConsumerWidget {
  const CalendarTaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTasksAsync = ref.watch(selectedDateTasksProvider);

    final dateFormatted = DateFormat('dd/MM/yyyy', 'vi').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Công việc ngày $dateFormatted',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () =>
                    _openTaskForm(context, ref, initialDueDate: selectedDate),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm task'),
              ),
            ],
          ),
        ),

        // Task Cards List
        selectedTasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildEmptyState(context, ref, selectedDate);
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskTile(context, ref, task);
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Đang tải công việc...'),
                ],
              ),
            ),
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text('Không thể tải công việc: $err'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(allTasksStreamProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, TaskEntity task) {
    String timeStr = 'Cả ngày';
    if (task.startTime != null && task.endTime != null) {
      timeStr = DateFormatter.formatTimeRange(task.startTime!, task.endTime!);
    } else if (task.startTime != null) {
      timeStr = DateFormatter.formatTime(task.startTime!);
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) {
            ref.read(toggleTaskCompletionUseCaseProvider)(task.id);
          },
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withAlpha(128)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                _buildPriorityBadge(task.priority),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Chỉnh sửa',
              onPressed: () => _openTaskForm(context, ref, taskToEdit: task),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: 'Xóa công việc',
              onPressed: () => _confirmDelete(context, ref, task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color bg;
    switch (priority) {
      case TaskPriority.urgent:
      case TaskPriority.high:
        bg = AppColors.error;
        break;
      case TaskPriority.medium:
        bg = AppColors.warning;
        break;
      case TaskPriority.low:
        bg = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(color: bg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Không có công việc nào cho ngày này',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  _openTaskForm(context, ref, initialDueDate: selectedDate),
              icon: const Icon(Icons.add_rounded),
              label: const Text('+ Thêm công việc'),
            ),
          ],
        ),
      ),
    );
  }

  void _openTaskForm(
    BuildContext context,
    WidgetRef ref, {
    TaskEntity? taskToEdit,
    DateTime? initialDueDate,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        taskToEdit: taskToEdit,
        initialDueDate: initialDueDate,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskEntity task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa công việc "${task.title}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(deleteTaskUseCaseProvider)(task.id);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
