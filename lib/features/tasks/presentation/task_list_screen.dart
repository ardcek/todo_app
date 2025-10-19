import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/core/theme/theme_controller.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/features/tasks/presentation/task_card.dart';
import 'package:todo_app/features/tasks/presentation/task_list_notifier.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building TaskListScreen');
    try {
      final l10n = L10n.of(context);
      final tasksAsync = ref.watch(taskListNotifierProvider);
      final filter = ref.watch(taskListNotifierProvider.notifier).currentFilter;
      final sort = ref.watch(taskListNotifierProvider.notifier).currentSort;

      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.tasks),
          actions: [
            IconButton(
              icon: Icon(
                ref.watch(themeControllerProvider) ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                ref.read(themeControllerProvider.notifier).toggleTheme();
              },
            ),
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                context.go('/settings/language');
              },
            ),
            PopupMenuButton<TaskFilter>(
              icon: const Icon(Icons.filter_list),
              initialValue: filter,
              onSelected: (filter) {
                ref.read(taskListNotifierProvider.notifier).setFilter(filter);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: TaskFilter.all,
                  child: Text(l10n.all),
                ),
                PopupMenuItem(
                  value: TaskFilter.active,
                  child: Text(l10n.incomplete),
                ),
                PopupMenuItem(
                  value: TaskFilter.completed,
                  child: Text(l10n.completed),
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
                PopupMenuItem(
                  value: TaskSort.dueDate,
                  child: Text(l10n.taskDueDate),
                ),
                PopupMenuItem(
                  value: TaskSort.created,
                  child: Text('Created'),
                ),
                PopupMenuItem(
                  value: TaskSort.alphabetical,
                  child: Text('A-Z'),
                ),
              ],
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            try {
              return tasksAsync.when(
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
                              l10n.noTasks,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.addYourFirstTask,
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: const PageStorageKey('taskList'),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
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
                              decoration: const BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
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
                          );
                        },
                      ),
              );
            } catch (e, stack) {
              debugPrint('Error in TaskListScreen body builder: $e');
              debugPrint('Stack trace: $stack');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error building task list: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/task/new'),
          child: const Icon(Icons.add),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error in TaskListScreen build: $e');
      debugPrint('Stack trace: $stack');
      return const Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Something went wrong\nPlease restart the app',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }
  }
}