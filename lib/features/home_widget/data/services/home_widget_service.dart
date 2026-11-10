import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../domain/models/home_widget_payload.dart';

/// Abstract contract for Home Screen Widget communication
abstract class IHomeWidgetService {
  Future<bool> updateWidgets(HomeWidgetPayload payload);
  Future<bool> clearWidgets();
  HomeWidgetPayload? get lastPayload;
}

/// Implementation using the home_widget package with deduplication and platform safety
class HomeWidgetServiceImpl implements IHomeWidgetService {
  static const String compactWidgetProviderName =
      'TimeflowWidgetCompactProvider';
  static const String expandedWidgetProviderName =
      'TimeflowWidgetExpandedProvider';

  HomeWidgetPayload? _lastPayload;

  @override
  HomeWidgetPayload? get lastPayload => _lastPayload;

  @override
  Future<bool> updateWidgets(HomeWidgetPayload payload) async {
    // 1. Guard platform: only Android supports this native widget provider
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _lastPayload = payload;
      debugPrint(
        '[HomeWidgetService] Non-Android platform (${defaultTargetPlatform.name}), skipping native widget update.',
      );
      return true;
    }

    // 2. Deduplication check: do not trigger native widget render if payload is identical
    if (_lastPayload != null && _lastPayload == payload) {
      debugPrint(
        '[HomeWidgetService] Duplicate payload detected, skipping native render.',
      );
      return true;
    }

    try {
      // 3. Save structured data into widget storage
      await HomeWidget.saveWidgetData<String>('headerDate', payload.headerDate);
      await HomeWidget.saveWidgetData<String>(
        'progressText',
        payload.progressFractionText,
      );
      await HomeWidget.saveWidgetData<int>(
        'progressPercent',
        payload.progressPercent,
      );
      await HomeWidget.saveWidgetData<int>(
        'totalTasksToday',
        payload.totalTasksToday,
      );
      await HomeWidget.saveWidgetData<int>(
        'completedTasksToday',
        payload.completedTasksToday,
      );

      // Current task data
      final hasCurrent = payload.hasCurrentTask;
      await HomeWidget.saveWidgetData<bool>('hasCurrentTask', hasCurrent);
      await HomeWidget.saveWidgetData<String>(
        'currentTaskTitle',
        hasCurrent
            ? payload.currentTask!.title
            : 'Không có công việc đang diễn ra',
      );
      await HomeWidget.saveWidgetData<String>(
        'currentTaskTime',
        hasCurrent ? (payload.currentTask!.timeRange ?? '') : '',
      );
      await HomeWidget.saveWidgetData<String>(
        'currentTaskPriority',
        hasCurrent ? payload.currentTask!.priority : '',
      );

      // Next task data
      final hasNext = payload.hasNextTask;
      await HomeWidget.saveWidgetData<bool>('hasNextTask', hasNext);
      await HomeWidget.saveWidgetData<String>(
        'nextTaskTitle',
        hasNext ? payload.nextTask!.title : 'Không có công việc tiếp theo',
      );
      await HomeWidget.saveWidgetData<String>(
        'nextTaskTime',
        hasNext ? (payload.nextTask!.timeRange ?? '') : '',
      );
      await HomeWidget.saveWidgetData<String>(
        'nextTaskPriority',
        hasNext ? payload.nextTask!.priority : '',
      );

      // Full serialized JSON payload
      await HomeWidget.saveWidgetData<String>(
        'payloadJson',
        jsonEncode(payload.toJson()),
      );

      // 4. Request native AppWidget updates for both sizes
      // qualifiedAndroidName used for reliability with home_widget 0.10.0
      await HomeWidget.updateWidget(
        name: compactWidgetProviderName,
        androidName: compactWidgetProviderName,
        qualifiedAndroidName:
            'com.timeflow.timeflow.$compactWidgetProviderName',
      );

      await HomeWidget.updateWidget(
        name: expandedWidgetProviderName,
        androidName: expandedWidgetProviderName,
        qualifiedAndroidName:
            'com.timeflow.timeflow.$expandedWidgetProviderName',
      );

      _lastPayload = payload;
      debugPrint(
        '[HomeWidgetService] Successfully updated Home Screen Widgets (compact & expanded).',
      );
      return true;
    } catch (e, stack) {
      debugPrint('[HomeWidgetService] Failed to update widgets: $e\n$stack');
      return false;
    }
  }

  @override
  Future<bool> clearWidgets() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _lastPayload = null;
      return true;
    }

    try {
      await HomeWidget.saveWidgetData<bool>('hasCurrentTask', false);
      await HomeWidget.saveWidgetData<bool>('hasNextTask', false);
      await HomeWidget.saveWidgetData<String>(
        'currentTaskTitle',
        'Không có công việc đang diễn ra',
      );
      await HomeWidget.saveWidgetData<String>(
        'nextTaskTitle',
        'Không có công việc tiếp theo',
      );
      await HomeWidget.saveWidgetData<String>('currentTaskTime', '');
      await HomeWidget.saveWidgetData<String>('nextTaskTime', '');
      await HomeWidget.saveWidgetData<String>('progressText', '0/0');
      await HomeWidget.saveWidgetData<int>('progressPercent', 0);

      await HomeWidget.updateWidget(
        name: compactWidgetProviderName,
        androidName: compactWidgetProviderName,
        qualifiedAndroidName:
            'com.timeflow.timeflow.$compactWidgetProviderName',
      );

      await HomeWidget.updateWidget(
        name: expandedWidgetProviderName,
        androidName: expandedWidgetProviderName,
        qualifiedAndroidName:
            'com.timeflow.timeflow.$expandedWidgetProviderName',
      );

      _lastPayload = null;
      return true;
    } catch (e) {
      debugPrint('[HomeWidgetService] Failed to clear widgets: $e');
      return false;
    }
  }
}
