import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/features/tasks/presentation/task_card.dart';
import 'package:todo_app/features/tasks/presentation/task_list_notifier.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListNotifierProvider);
    final filter = ref.watch(taskListNotifierProvider.notifier).currentFilter;
    final sort = ref.watch(taskListNotifierProvider.notifier).currentSort;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            initialValue: filter,
            onSelected: (filter) {
              ref.read(taskListNotifierProvider.notifier).setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskFilter.all,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: TaskFilter.active,
                child: Text('Active'),
              ),
              const PopupMenuItem(
                value: TaskFilter.completed,
                child: Text('Completed'),
              ),
            ],
          ),
          PopupMenuButton<TaskSort>(
            icon: const Icon(Icons.sort),
            initialValue: sort,
            onSelected: (sort) {
              ref.read(taskListNotifierProvider.notifier).setSort(sort);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskSort.priority,
                child: Text('Priority'),
              ),
              const PopupMenuItem(
                value: TaskSort.dueDate,
                child: Text('Due Date'),
              ),
              const PopupMenuItem(
                value: TaskSort.created,
                child: Text('Created'),
              ),
              const PopupMenuItem(
                value: TaskSort.alphabetical,
                child: Text('Alphabetical'),
              ),
            ],
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ],
          ),
        ),
        data: (tasks) => tasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new task',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : AnimatedList(
                initialItemCount: tasks.length,
                padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                itemBuilder: (context, index, animation) {
                  final task = tasks[index];
                  return SlideTransition(
                    position: animation.drive(Tween(
                      begin: const Offset(1, 0),
                      end: const Offset(0, 0),
                    ).chain(CurveTween(curve: Curves.easeOut))),
                    child: Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          ref
                              .read(taskListNotifierProvider.notifier)
                              .deleteTask(task);
                        } else {
                          ref
                              .read(taskListNotifierProvider.notifier)
                              .toggleTaskCompleted(task);
                        }
                      },
                      background: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const Icon(Icons.check_circle_outline, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: TaskCard(
                        task: task,
                        onTap: () => context.go('/task/edit', extra: task),
                        onCheckboxChanged: (value) {
                          ref
                              .read(taskListNotifierProvider.notifier)
                              .toggleTaskCompleted(task);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/task/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}