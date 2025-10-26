import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.tasks,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1),
          ),
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
                loading: () => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (tasks) => tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.task_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.noTasks,
                              style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.addYourFirstTask,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                height: 1.4,
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
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 24),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: const Icon(Icons.check_circle_outline, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.error,
                                    Theme.of(context).colorScheme.error.withOpacity(0.8),
                                  ],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                ),
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
                              onUpdate: (updatedTask) {
                                ref
                                    .read(taskListNotifierProvider.notifier)
                                    .updateTask(updatedTask);
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
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => context.go('/task/new'),
            icon: const Icon(Icons.add),
            label: Text(
              l10n.addTask,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
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