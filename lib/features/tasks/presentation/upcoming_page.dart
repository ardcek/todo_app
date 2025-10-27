import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_stats_widget.dart';
import 'package:todo_app/features/tasks/presentation/today_page.dart' as today;
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/features/tasks/presentation/edit_task_dialog.dart';

class UpcomingPage extends ConsumerWidget {
  const UpcomingPage({super.key});

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    if (dateOnly == today) return 'Bugün $time';
    final tomorrow = today.add(const Duration(days: 1));
    if (dateOnly == tomorrow) return 'Yarın $time';
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')} $time';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(today.todayTasksProvider);
    final tasks = ref.read(today.todayTasksProvider.notifier).upcomingTasks;
    final language = ref.watch(languageControllerProvider);
    
    // Calculate stats
    final completedCount = tasks.where((t) => t.completed).length;
    final remainingCount = tasks.where((t) => !t.completed).length;
    final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              language == 'en' ? 'No upcoming tasks' : 'Yaklaşan görev yok',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              language == 'en'
                ? 'Future tasks will appear here'
                : 'Gelecek tarihli görevler burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TaskStatsWidget(
          completed: completedCount,
          remaining: remainingCount,
          progress: progress,
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
        final t = tasks[index];
        final actualIndex = allTasks.indexOf(t);
        return RepaintBoundary(
          child: TaskCard(
            taskId: t.id,
            title: t.title,
            priority: Priority.values[t.priorityIdx],
            dueLabel: t.dueLabel,
            completed: t.completed,
            currentDueDate: t.dueDate,
            notes: t.notes,
            onToggle: (v) => ref.read(today.todayTasksProvider.notifier).toggle(actualIndex, v ?? false),
            onTap: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => EditTaskDialog(
                  taskId: t.id,
                  initialTitle: t.title,
                  initialPriority: Priority.values[t.priorityIdx],
                  initialDueDate: t.dueDate,
                  initialNotes: t.notes,
                ),
              );
              if (result != null) {
                final title = result['title'] as String;
                final priority = result['priority'] as int;
                final dueDate = result['dueDate'] as DateTime?;
                final notes = result['notes'] as String?;
                
                if (title.isNotEmpty) {
                  t.title = title;
                }
                t.priorityIdx = priority;
                t.dueDate = dueDate;
                t.dueLabel = dueDate != null ? _formatDateTime(dueDate) : null;
                t.notes = notes;
                
                ref.read(today.todayTasksProvider.notifier).updateTask(
                  actualIndex,
                  dueLabel: t.dueLabel,
                  dueDate: t.dueDate,
                );
              }
            },
            onSnooze: (newDateTime) {
              final formattedLabel = _formatDateTime(newDateTime);
              ref.read(today.todayTasksProvider.notifier).updateTask(
                actualIndex,
                dueLabel: formattedLabel,
                dueDate: newDateTime,
              );
            },
            onDelete: () {
              final removed = tasks[index];
              ref.read(today.todayTasksProvider.notifier).removeAt(actualIndex);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Silindi'),
                  action: SnackBarAction(
                    label: 'Geri al',
                    onPressed: () => ref.read(today.todayTasksProvider.notifier).add(removed),
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
        ),
      ],
    );
  }
}


