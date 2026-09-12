import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import 'providers/calendar_providers.dart';
import 'widgets/calendar_header.dart';
import 'widgets/calendar_month_view.dart';
import 'widgets/calendar_task_list.dart';

/// Interactive Calendar Screen connected to SQLite Database
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= AppConstants.kMobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch trình công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () {
              ref.invalidate(selectedDateTasksProvider);
              ref.invalidate(monthTaskCountsProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CalendarHeader(),
          CalendarMonthView(),
          SizedBox(height: 16),
          Divider(height: 1),
          CalendarTaskList(),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane: Calendar Month View
          Expanded(
            flex: 5,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CalendarHeader(),
                    SizedBox(height: 8),
                    CalendarMonthView(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right Pane: Selected Date Tasks List
          Expanded(
            flex: 4,
            child: Card(
              child: SingleChildScrollView(child: const CalendarTaskList()),
            ),
          ),
        ],
      ),
    );
  }
}
