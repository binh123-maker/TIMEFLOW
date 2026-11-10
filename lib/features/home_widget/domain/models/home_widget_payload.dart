import 'package:flutter/foundation.dart';

/// Summary of a single task formatted for Home Screen Widget consumption
@immutable
class HomeWidgetTaskSummary {
  final String id;
  final String title;
  final String? description;
  final String? timeRange;
  final String priority;
  final bool isCompleted;

  const HomeWidgetTaskSummary({
    required this.id,
    required this.title,
    this.description,
    this.timeRange,
    required this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (timeRange != null) 'timeRange': timeRange,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory HomeWidgetTaskSummary.fromJson(Map<String, dynamic> json) {
    return HomeWidgetTaskSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      timeRange: json['timeRange'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeWidgetTaskSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          timeRange == other.timeRange &&
          priority == other.priority &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      Object.hash(id, title, description, timeRange, priority, isCompleted);
}

/// Root data payload synchronized to Android Home Screen Widgets
@immutable
class HomeWidgetPayload {
  final int version;
  final HomeWidgetTaskSummary? currentTask;
  final HomeWidgetTaskSummary? nextTask;
  final int totalTasksToday;
  final int completedTasksToday;
  final String headerDate;
  final DateTime lastUpdatedAt;

  HomeWidgetPayload({
    this.version = 1,
    this.currentTask,
    this.nextTask,
    this.totalTasksToday = 0,
    this.completedTasksToday = 0,
    required this.headerDate,
    DateTime? lastUpdatedAt,
  }) : lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  bool get hasCurrentTask => currentTask != null;
  bool get hasNextTask => nextTask != null;
  bool get hasAnyActiveTask => hasCurrentTask || hasNextTask;

  int get progressPercent {
    if (totalTasksToday <= 0) return 0;
    return ((completedTasksToday / totalTasksToday) * 100).round().clamp(
      0,
      100,
    );
  }

  String get progressFractionText => '$completedTasksToday/$totalTasksToday';

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'currentTask': currentTask?.toJson(),
      'nextTask': nextTask?.toJson(),
      'totalTasksToday': totalTasksToday,
      'completedTasksToday': completedTasksToday,
      'headerDate': headerDate,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory HomeWidgetPayload.fromJson(Map<String, dynamic> json) {
    return HomeWidgetPayload(
      version: json['version'] as int? ?? 1,
      currentTask: json['currentTask'] != null && json['currentTask'] is Map
          ? HomeWidgetTaskSummary.fromJson(
              Map<String, dynamic>.from(json['currentTask'] as Map),
            )
          : null,
      nextTask: json['nextTask'] != null && json['nextTask'] is Map
          ? HomeWidgetTaskSummary.fromJson(
              Map<String, dynamic>.from(json['nextTask'] as Map),
            )
          : null,
      totalTasksToday: json['totalTasksToday'] as int? ?? 0,
      completedTasksToday: json['completedTasksToday'] as int? ?? 0,
      headerDate: json['headerDate'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeWidgetPayload &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          currentTask == other.currentTask &&
          nextTask == other.nextTask &&
          totalTasksToday == other.totalTasksToday &&
          completedTasksToday == other.completedTasksToday &&
          headerDate == other.headerDate;

  @override
  int get hashCode => Object.hash(
    version,
    currentTask,
    nextTask,
    totalTasksToday,
    completedTasksToday,
    headerDate,
  );
}
