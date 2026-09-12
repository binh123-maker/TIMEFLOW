import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/calendar_providers.dart';

class CalendarMonthView extends ConsumerWidget {
  const CalendarMonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedMonth = ref.watch(displayedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final monthTaskCountsAsync = ref.watch(monthTaskCountsProvider);

    final today = DateTime.now();

    // 1. Calculate Grid Days (Monday-based start)
    final firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    // Monday = 1, Sunday = 7 -> leading offset (Monday-based: Monday -> 0, Sunday -> 6)
    final leadingDays = firstDayOfMonth.weekday - 1;

    final List<DateTime> gridDays = [];

    // Add trailing days from previous month
    for (int i = leadingDays; i > 0; i--) {
      gridDays.add(firstDayOfMonth.subtract(Duration(days: i)));
    }

    // Add days of current month
    for (int i = 0; i < daysInMonth; i++) {
      gridDays.add(DateTime(displayedMonth.year, displayedMonth.month, i + 1));
    }

    // Add leading days for next month to complete 7-column rows
    final remainingDays = (7 - (gridDays.length % 7)) % 7;
    final lastDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      daysInMonth,
    );
    for (int i = 1; i <= remainingDays; i++) {
      gridDays.add(lastDayOfMonth.add(Duration(days: i)));
    }

    final taskCountsMap = monthTaskCountsAsync.value ?? {};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // Weekday Labels Row (T2 -> CN)
          Row(
            children: const [
              _WeekdayLabel('T2'),
              _WeekdayLabel('T3'),
              _WeekdayLabel('T4'),
              _WeekdayLabel('T5'),
              _WeekdayLabel('T6'),
              _WeekdayLabel('T7'),
              _WeekdayLabel('CN'),
            ],
          ),
          const SizedBox(height: 8),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final cellDate = gridDays[index];
              final isCurrentMonth = cellDate.month == displayedMonth.month;
              final isSelected = DateFormatter.isSameDay(
                cellDate,
                selectedDate,
              );
              final isToday = DateFormatter.isSameDay(cellDate, today);

              // Normalize date for task count lookup
              final key = DateTime(cellDate.year, cellDate.month, cellDate.day);
              final taskCount = taskCountsMap[key] ?? 0;

              return _buildDayCell(
                context,
                ref,
                cellDate: cellDate,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected,
                isToday: isToday,
                taskCount: taskCount,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    WidgetRef ref, {
    required DateTime cellDate,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isToday,
    required int taskCount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (!isCurrentMonth) {
      textColor = colorScheme.onSurface.withAlpha(90);
    } else if (isToday) {
      textColor = colorScheme.primary;
    } else {
      textColor = colorScheme.onSurface;
    }

    BoxDecoration? cellDecoration;
    if (isSelected) {
      cellDecoration = BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (isToday) {
      cellDecoration = BoxDecoration(
        border: Border.all(color: colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Click date: Update selectedDate AND displayedMonth if adjacent month
        ref.read(selectedDateProvider.notifier).selectDate(cellDate);
        if (cellDate.month != ref.read(displayedMonthProvider).month ||
            cellDate.year != ref.read(displayedMonthProvider).year) {
          ref.read(displayedMonthProvider.notifier).setMonth(cellDate);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: cellDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${cellDate.day}',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            _buildDotIndicators(
              context,
              taskCount: taskCount,
              isSelected: isSelected,
            ),
          ],
        ),
      ),
    );
  }

  /// Dot Indicator Level: 0 -> none, 1 -> 1 dot, 2 -> 2 dots, 3+ -> 3 dots max
  Widget _buildDotIndicators(
    BuildContext context, {
    required int taskCount,
    required bool isSelected,
  }) {
    if (taskCount == 0) {
      return const SizedBox(height: 6);
    }

    final int dotCount = taskCount > 3 ? 3 : taskCount;
    final dotColor = isSelected ? Colors.white : AppColors.primary;

    return SizedBox(
      height: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(dotCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          );
        }),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
