import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/entities/task_entity.dart';
import 'providers/task_providers.dart';
import 'widgets/task_form_dialog.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _filterIndex = 0; // 0: Tất cả, 1: Chưa xong, 2: Đã hoàn thành
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Thêm công việc mới',
            onPressed: () => _openTaskForm(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs & Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm công việc...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(0, 'Tất cả'),
                    const SizedBox(width: 8),
                    _buildFilterChip(1, 'Chưa xong'),
                    const SizedBox(width: 8),
                    _buildFilterChip(2, 'Đã hoàn thành'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Real SQLite Tasks List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Apply Search & Tab Filter
                final searchQuery = _searchController.text.trim().toLowerCase();
                var filtered = tasks.where((t) {
                  if (searchQuery.isNotEmpty &&
                      !t.title.toLowerCase().contains(searchQuery) &&
                      !(t.description?.toLowerCase().contains(searchQuery) ??
                          false)) {
                    return false;
                  }
                  if (_filterIndex == 1) return !t.isCompleted;
                  if (_filterIndex == 2) return t.isCompleted;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return _buildTaskTile(context, task);
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Đang tải dữ liệu...'),
                  ],
                ),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text('Đã xảy ra lỗi: $err'),
                    const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filterIndex = index;
        });
      },
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskEntity task) {
    final timeFormatter = DateFormat('HH:mm dd/MM', 'vi');
    String? timeRangeStr;
    if (task.startTime != null && task.endTime != null) {
      timeRangeStr =
          '${DateFormat('HH:mm', 'vi').format(task.startTime!)} - ${DateFormat('HH:mm dd/MM', 'vi').format(task.endTime!)}';
    } else if (task.dueDate != null) {
      timeRangeStr = timeFormatter.format(task.dueDate!);
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              const SizedBox(height: 4),
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (timeRangeStr != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeRangeStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                _buildPriorityBadge(task.priority),
                _buildStatusBadge(context, task.status),
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
              onPressed: () => _openTaskForm(context, taskToEdit: task),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: 'Xóa công việc',
              onPressed: () => _confirmDelete(context, task),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bg.withAlpha(100), width: 0.8),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(color: bg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TaskStatus status) {
    Color bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    Color fg = Theme.of(context).colorScheme.onSurfaceVariant;

    if (status == TaskStatus.completed) {
      bg = AppColors.success.withAlpha(40);
      fg = AppColors.success;
    } else if (status == TaskStatus.inProgress) {
      bg = AppColors.primary.withAlpha(40);
      fg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có công việc nào',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút bên dưới để tạo công việc đầu tiên của bạn!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openTaskForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('+ Thêm công việc'),
            ),
          ],
        ),
      ),
    );
  }

  void _openTaskForm(BuildContext context, {TaskEntity? taskToEdit}) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(taskToEdit: taskToEdit),
    );
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
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
