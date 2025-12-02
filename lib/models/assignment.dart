import 'package:flutter/material.dart';

enum AssignmentPriority { low, medium, high }

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final DateTime dueDate;
  final AssignmentPriority priority;
  final bool completed;
  final DateTime? completedDate;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.dueDate,
    this.priority = AssignmentPriority.medium,
    this.completed = false,
    this.completedDate,
  });

  // Check if assignment is overdue
  bool get isOverdue {
    return !completed && DateTime.now().isAfter(dueDate);
  }

  // Check if due today
  bool get isDueToday {
    final now = DateTime.now();
    return !completed &&
        dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  // Check if due tomorrow
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return !completed &&
        dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  // Days until due
  int get daysUntilDue {
    if (completed) return 0;
    final now = DateTime.now();
    final difference = dueDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Get priority color
  Color get priorityColor {
    switch (priority) {
      case AssignmentPriority.high:
        return Colors.red;
      case AssignmentPriority.medium:
        return Colors.orange;
      case AssignmentPriority.low:
        return Colors.blue;
    }
  }

  // Get priority label
  String get priorityLabel {
    switch (priority) {
      case AssignmentPriority.high:
        return 'High';
      case AssignmentPriority.medium:
        return 'Medium';
      case AssignmentPriority.low:
        return 'Low';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index,
      'completed': completed,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      subjectId: json['subjectId'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: AssignmentPriority.values[json['priority'] ?? 1],
      completed: json['completed'] ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    DateTime? dueDate,
    AssignmentPriority? priority,
    bool? completed,
    DateTime? completedDate,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}