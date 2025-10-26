import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/presentation/today_page.dart';

class Project {
  Project({
    required this.name,
    required this.id,
    this.color,
    this.icon,
    List<DemoTask>? tasks,
  }) : tasks = tasks ?? [];

  final String id;
  final String name;
  final Color? color;
  final IconData? icon;
  final List<DemoTask> tasks;

  int get completedCount => tasks.where((t) => t.completed).length;
  int get totalCount => tasks.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}
