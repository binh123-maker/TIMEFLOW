import 'package:flutter/material.dart';

enum TaskStatus {
  upcoming,
  inProgress,
  completed,
}

enum TaskPriority {
  low,
  medium,
  high,
}

/// Data model representing a Task / Event in TIMEFLOW
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final Color categoryColor;
  final TaskStatus status;
  final TaskPriority priority;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.categoryColor,
    this.status = TaskStatus.upcoming,
    this.priority = TaskPriority.medium,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    Color? categoryColor,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}
