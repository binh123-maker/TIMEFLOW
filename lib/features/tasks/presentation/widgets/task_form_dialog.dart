import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskEntity? taskToEdit;

  const TaskFormDialog({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late TaskPriority _priority;
  late TaskStatus _status;

  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.taskToEdit;

    _titleController = TextEditingController(text: edit?.title ?? '');
    _descriptionController = TextEditingController(
      text: edit?.description ?? '',
    );

    _selectedDate = edit?.dueDate ?? edit?.startTime ?? DateTime.now();
    _startTime = edit?.startTime != null
        ? TimeOfDay.fromDateTime(edit!.startTime!)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = edit?.endTime != null
        ? TimeOfDay.fromDateTime(edit!.endTime!)
        : const TimeOfDay(hour: 10, minute: 0);

    _priority = edit?.priority ?? TaskPriority.medium;
    _status = edit?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _errorMessage = null;
    });

    final titleText = _titleController.text.trim();
    if (titleText.isEmpty) {
      setState(() {
        _errorMessage = 'Tiêu đề công việc không được để trống.';
      });
      return;
    }

    DateTime? fullStart;
    DateTime? fullEnd;

    if (_startTime != null) {
      fullStart = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    if (_endTime != null) {
      fullEnd = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    if (fullStart != null && fullEnd != null && !fullStart.isBefore(fullEnd)) {
      setState(() {
        _errorMessage = 'Thời gian bắt đầu phải trước thời gian kết thúc.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.taskToEdit == null) {
        // Create Task
        final createTask = ref.read(createTaskUseCaseProvider);
        await createTask(
          title: titleText,
          description: _descriptionController.text,
          status: _status,
          priority: _priority,
          dueDate: _selectedDate,
          startTime: fullStart,
          endTime: fullEnd,
        );
      } else {
        // Update Task
        final updateTask = ref.read(updateTaskUseCaseProvider);
        final updated = widget.taskToEdit!.copyWith(
          title: titleText,
          description: _descriptionController.text,
          status: _status,
          priority: _priority,
          dueDate: _selectedDate,
          startTime: fullStart,
          endTime: fullEnd,
          isCompleted: _status == TaskStatus.completed,
        );
        await updateTask(updated);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('ArgumentError: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    final dateStr = DateFormat('dd/MM/yyyy', 'vi').format(_selectedDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Chỉnh sửa công việc' : 'Thêm công việc mới',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề công việc *',
                    hintText: 'Nhập tên công việc...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả (tùy chọn)',
                    hintText: 'Thêm chi tiết...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                // Date Picker Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày thực hiện',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(dateStr),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Time Pickers Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Bắt đầu',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time_rounded),
                          ),
                          child: Text(_startTime?.format(context) ?? 'Chọn'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Kết thúc',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time_filled_rounded),
                          ),
                          child: Text(_endTime?.format(context) ?? 'Chọn'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Priority Dropdown
                DropdownButtonFormField<TaskPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Mức độ ưu tiên',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _priority = val);
                  },
                ),
                const SizedBox(height: 14),
                // Status Dropdown
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: TaskStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitForm,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(isEditing ? 'Cập nhật' : 'Lưu công việc'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
