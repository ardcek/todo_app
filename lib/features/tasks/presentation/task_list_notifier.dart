import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/features/tasks/data/task_repository.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/core/database/database.dart' as db;

part 'task_list_notifier.g.dart';

enum TaskFilter {
  all,
  active,
  completed,
}

enum TaskSort {
  priority,
  dueDate,
  created,
  alphabetical,
}

@riverpod
class TaskListNotifier extends _$TaskListNotifier {
  @override
  Future<List<Task>> build() async {
    try {
      _filter = TaskFilter.all;
      _sort = TaskSort.created;
      debugPrint('Building TaskListNotifier');
      return await _loadAndFilterTasks();
    } catch (e, stack) {
      debugPrint('Error in TaskListNotifier build: $e');
      debugPrint('Stack trace: $stack');
      return [];  // Return empty list instead of throwing
    }
  }

  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.created;

  TaskFilter get currentFilter => _filter;
  TaskSort get currentSort => _sort;

  Future<void> setFilter(TaskFilter filter) async {
    _filter = filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAndFilterTasks());
  }

  Future<void> setSort(TaskSort sort) async {
    _sort = sort;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAndFilterTasks());
  }

  Future<void> toggleTaskCompleted(Task task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await ref.read(taskRepositoryProvider).updateTask(updatedTask);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAndFilterTasks());
  }

  Future<void> deleteTask(Task task) async {
    await ref.read(taskRepositoryProvider).deleteTask(task.id);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAndFilterTasks());
  }

  Future<List<Task>> _loadAndFilterTasks() async {
    try {
      debugPrint('Loading and filtering tasks...');
      List<Task> allTasks = await ref.read(taskRepositoryProvider).getAllTasks();
      
      // Retry if no tasks found
      if (allTasks.isEmpty) {
        for (int retries = 0; retries < 2; retries++) {
          debugPrint('No tasks found, retry ${retries + 1}/2...');
          await Future.delayed(const Duration(milliseconds: 500));
          allTasks = await ref.read(taskRepositoryProvider).getAllTasks();
          if (allTasks.isNotEmpty) break;
        }
      }
      
      debugPrint('Loaded ${allTasks.length} tasks');
      
      // Filter and sort tasks
      var filteredTasks = allTasks.where((task) {
        switch (_filter) {
          case TaskFilter.all:
            return true;
          case TaskFilter.active:
            return !task.completed;
          case TaskFilter.completed:
            return task.completed;
        }
      }).toList();

      filteredTasks.sort((a, b) {
        switch (_sort) {
          case TaskSort.priority:
            return b.priority.compareTo(a.priority);
          case TaskSort.dueDate:
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          case TaskSort.created:
            return b.createdAt.compareTo(a.createdAt);
          case TaskSort.alphabetical:
            return a.title.compareTo(b.title);
        }
      });

      return filteredTasks.map((task) => Task(
        id: task.id,
        title: task.title,
        note: task.note,
        dueDate: task.dueDate,
        reminderDate: task.reminderDate,
        priority: task.priority,
        project: task.project,
        completed: task.completed,
        orderIndex: task.orderIndex,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        deletedAt: task.deletedAt
      )).toList();
    } catch (e, stack) {
      debugPrint('Error loading tasks: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }
}