import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/features/tasks/presentation/edit_task_dialog.dart';

class DemoTask {
  DemoTask({
    required this.title,
    required this.priorityIdx,
    this.dueLabel,
    this.dueDate,
  });
  String title;
  int priorityIdx;
  String? dueLabel;
  DateTime? dueDate;
  bool completed = false;
}

class TodayTasksNotifier extends StateNotifier<List<DemoTask>> {
  TodayTasksNotifier() : super([]);

  void add(DemoTask task) => state = [task, ...state];
  void removeAt(int index) => state = [...state]..removeAt(index);
  void toggle(int index, bool value) {
    final copy = [...state];
    copy[index].completed = value;
    state = copy;
  }

  void updateTask(int index, {String? dueLabel, DateTime? dueDate}) {
    final copy = [...state];
    if (dueLabel != null) copy[index].dueLabel = dueLabel;
    if (dueDate != null) copy[index].dueDate = dueDate;
    state = copy;
  }

  // Filter tasks by date
  List<DemoTask> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.where((task) {
      if (task.dueLabel == null) return true; // No date = today
      if (task.dueLabel!.startsWith('Bugün')) return true;
      return false;
    }).toList();
  }

  List<DemoTask> get upcomingTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.where((task) {
      if (task.dueLabel == null) return false;
      if (task.dueLabel!.startsWith('Bugün')) return false;
      return true; // Tomorrow or later
    }).toList();
  }
}

final todayTasksProvider = StateNotifierProvider<TodayTasksNotifier, List<DemoTask>>((ref) => TodayTasksNotifier());

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

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
    final allTasks = ref.watch(todayTasksProvider);
    final tasks = ref.read(todayTasksProvider.notifier).todayTasks;
    final language = ref.watch(languageControllerProvider);
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              language == 'en' ? 'No tasks for today' : 'Bugün için görev yok',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              language == 'en' 
                ? 'Tap the + button to add a new task'
                : 'Yeni görev eklemek için + butonuna tıklayın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Semantics(
      header: true,
      container: true,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          final t = tasks[index];
          final actualIndex = allTasks.indexOf(t);
          return RepaintBoundary(
            child: TaskCard(
              title: t.title,
              priority: Priority.values[t.priorityIdx],
              dueLabel: t.dueLabel,
              completed: t.completed,
              currentDueDate: t.dueDate,
              onToggle: (v) => ref.read(todayTasksProvider.notifier).toggle(actualIndex, v ?? false),
              onTap: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => EditTaskDialog(
                    initialTitle: t.title,
                    initialPriority: Priority.values[t.priorityIdx],
                    initialDueDate: t.dueDate,
                  ),
                );
                if (result != null) {
                  final title = result['title'] as String;
                  final priority = result['priority'] as int;
                  final dueDate = result['dueDate'] as DateTime?;
                  
                  if (title.isNotEmpty) {
                    t.title = title;
                  }
                  t.priorityIdx = priority;
                  t.dueDate = dueDate;
                  t.dueLabel = dueDate != null ? _formatDateTime(dueDate) : null;
                  
                  ref.read(todayTasksProvider.notifier).updateTask(
                    actualIndex,
                    dueLabel: t.dueLabel,
                    dueDate: t.dueDate,
                  );
                }
              },
              onSnooze: (newDateTime) {
                final formattedLabel = _formatDateTime(newDateTime);
                ref.read(todayTasksProvider.notifier).updateTask(
                  actualIndex,
                  dueLabel: formattedLabel,
                  dueDate: newDateTime,
                );
              },
              onDelete: () {
                final removed = tasks[index];
                ref.read(todayTasksProvider.notifier).removeAt(actualIndex);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Silindi'),
                    action: SnackBarAction(
                      label: 'Geri al',
                      onPressed: () => ref.read(todayTasksProvider.notifier).add(removed),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

 


