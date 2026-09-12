import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_providers.dart';

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedMonth = ref.watch(displayedMonthProvider);
    final monthStr = DateFormat('MMMM, yyyy', 'vi').format(displayedMonth);
    // Capitalize month name in Vietnamese
    final formattedMonthStr =
        monthStr.substring(0, 1).toUpperCase() + monthStr.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedMonthStr,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).selectToday();
                  ref
                      .read(displayedMonthProvider.notifier)
                      .selectCurrentMonth();
                },
                icon: const Icon(Icons.today_rounded, size: 18),
                label: const Text('Hôm nay'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Tháng trước',
                onPressed: () {
                  ref.read(displayedMonthProvider.notifier).previousMonth();
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Tháng sau',
                onPressed: () {
                  ref.read(displayedMonthProvider.notifier).nextMonth();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
