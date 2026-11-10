import 'package:flutter/foundation.dart';

/// Summary of a single task formatted for lockscreen / notification consumption
@immutable
class LockscreenTaskSummary {
  final String id;
  final String title;
  final String? description;
  final String? timeRange;
  final String priority;
  final bool isCompleted;

  const LockscreenTaskSummary({
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

  factory LockscreenTaskSummary.fromJson(Map<String, dynamic> json) {
    return LockscreenTaskSummary(
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
      other is LockscreenTaskSummary &&
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

/// Root data payload sent to Android Native Ongoing Notification
@immutable
class LockscreenPayload {
  final int version;
  final LockscreenTaskSummary? currentTask;
  final LockscreenTaskSummary? nextTask;
  final int totalTasksToday;
  final int completedTasksToday;
  final String headerDate;

  const LockscreenPayload({
    this.version = 1,
    this.currentTask,
    this.nextTask,
    this.totalTasksToday = 0,
    this.completedTasksToday = 0,
    required this.headerDate,
  });

  bool get hasActiveTasks => currentTask != null || nextTask != null;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'currentTask': currentTask?.toJson(),
      'nextTask': nextTask?.toJson(),
      'totalTasksToday': totalTasksToday,
      'completedTasksToday': completedTasksToday,
      'headerDate': headerDate,
    };
  }

  factory LockscreenPayload.fromJson(Map<String, dynamic> json) {
    return LockscreenPayload(
      version: json['version'] as int? ?? 1,
      currentTask: json['currentTask'] != null && json['currentTask'] is Map
          ? LockscreenTaskSummary.fromJson(
              Map<String, dynamic>.from(json['currentTask'] as Map),
            )
          : null,
      nextTask: json['nextTask'] != null && json['nextTask'] is Map
          ? LockscreenTaskSummary.fromJson(
              Map<String, dynamic>.from(json['nextTask'] as Map),
            )
          : null,
      totalTasksToday: json['totalTasksToday'] as int? ?? 0,
      completedTasksToday: json['completedTasksToday'] as int? ?? 0,
      headerDate: json['headerDate'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockscreenPayload &&
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
