import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/today_schedule_provider.dart';
import 'widgets/current_task_card.dart';
import 'widgets/next_task_card.dart';
import 'widgets/timeline_schedule_widget.dart';

/// Home / Today Screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveClockAsync = ref.watch(liveClockProvider);
    final currentTaskAsync = ref.watch(currentTaskProvider);
    final nextTaskAsync = ref.watch(nextTaskProvider);
    final todayTasksAsync = ref.watch(todayTasksProvider);

    final now = liveClockAsync.value ?? DateTime.now();
    final dateFormatted = DateFormatter.formatHeaderDate(now);
    final timeFormatted = DateFormatter.formatTime(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hôm nay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Thông báo',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không có thông báo mới')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayTasksProvider);
          ref.invalidate(currentTaskProvider);
          ref.invalidate(nextTaskProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Real-time Date and Live Clock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormatted,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lịch trình của bạn',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeFormatted,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current Task Section
              Text(
                'Công việc hiện tại',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              currentTaskAsync.when(
                data: (task) => CurrentTaskCard(task: task),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Lỗi: $err'),
              ),
              const SizedBox(height: 20),

              // Next Task Section
              Text(
                'Công việc tiếp theo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              nextTaskAsync.when(
                data: (task) => NextTaskCard(task: task),
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Timeline Schedule Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch trình trong ngày',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Lọc'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              todayTasksAsync.when(
                data: (tasks) => TimelineScheduleWidget(tasks: tasks),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Lỗi tải danh sách: $err'),
              ),
              const SizedBox(height: 80), // Padding for FloatingActionButton / BottomNav
            ],
          ),
        ),
      ),
    );
  }
}
