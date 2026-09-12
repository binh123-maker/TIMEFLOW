import 'package:flutter/material.dart';
import '../../../../data/models/task_model.dart';
import '../../../../core/utils/date_formatter.dart';

class NextTaskCard extends StatelessWidget {
  final TaskModel? task;

  const NextTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                color: Theme.of(context).colorScheme.outline,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Không có công việc tiếp theo trong hôm nay',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timeStr = DateFormatter.formatTimeRange(task!.startTime, task!.endTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: task!.categoryColor.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: task!.categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CÔNG VIỆC TIẾP THEO',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                      ),
                      Text(
                        timeStr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task!.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
