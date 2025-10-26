import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/presentation/models/project_model.dart';
import 'package:todo_app/features/tasks/presentation/today_page.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:todo_app/features/tasks/presentation/projects_page.dart';
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/features/timer/presentation/timer_widget.dart';
import 'package:todo_app/features/tasks/presentation/edit_task_dialog.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key, required this.project});

  final Project project;

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  void _addTask(String title, int priorityIdx, DateTime? dueDate) {
    final language = ref.read(languageControllerProvider);
    final newTask = DemoTask(
      title: title.isEmpty 
        ? (language == 'en' ? 'Unnamed Task' : 'Adsız Görev')
        : title,
      priorityIdx: priorityIdx,
      dueLabel: dueDate != null ? _formatDateTime(dueDate) : null,
      dueDate: dueDate,
    );
    
    setState(() {
      _project.tasks.insert(0, newTask);
    });
    
    // Update project in provider
    ref.read(projectsProvider.notifier).updateProject(_project);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == 'en' ? 'Task added' : 'Görev eklendi',
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final language = ref.read(languageControllerProvider);
    final titleController = TextEditingController();
    int selectedPriority = 1;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(language == 'en' ? 'New Task' : 'Yeni Görev'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: language == 'en' ? 'Task title' : 'Görev başlığı',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Date picker button
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate != null
                        ? _formatDateTime(selectedDate!)
                        : (language == 'en' ? 'Select date' : 'Tarih seç'),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                if (selectedDate != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setDialogState(() => selectedDate = null),
                    icon: const Icon(Icons.clear),
                    label: Text(language == 'en' ? 'Clear date' : 'Tarihi temizle'),
                  ),
                ],
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text(language == 'en' ? 'Low' : 'Düşük'),
                      icon: const Icon(Icons.flag, size: 16),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text(language == 'en' ? 'Med' : 'Orta'),
                      icon: const Icon(Icons.flag, size: 16),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text(language == 'en' ? 'High' : 'Yüksek'),
                      icon: const Icon(Icons.flag, size: 16),
                    ),
                  ],
                  selected: {selectedPriority},
                  onSelectionChanged: (Set<int> newSelection) {
                    setDialogState(() {
                      selectedPriority = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(language == 'en' ? 'Cancel' : 'İptal'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                _addTask(title, selectedPriority, selectedDate);
                Navigator.pop(context);
              },
              child: Text(language == 'en' ? 'Add' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageControllerProvider);
    final color = _project.color ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
      ),
      body: Column(
        children: [
          // Timer widget
          const TimerWidget(),
          
          // Project stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.check_circle_outline,
                      label: language == 'en' ? 'Completed' : 'Tamamlanan',
                      value: '${_project.completedCount}',
                      color: Colors.green,
                    ),
                    _StatItem(
                      icon: Icons.pending_outlined,
                      label: language == 'en' ? 'Remaining' : 'Kalan',
                      value: '${_project.totalCount - _project.completedCount}',
                      color: Colors.orange,
                    ),
                    _StatItem(
                      icon: Icons.analytics_outlined,
                      label: language == 'en' ? 'Progress' : 'İlerleme',
                      value: '${(_project.progress * 100).toInt()}%',
                      color: color,
                    ),
                  ],
                ),
                if (_project.totalCount > 0) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _project.progress,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Tasks list
          Expanded(
            child: _project.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 80,
                          color: color.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          language == 'en' ? 'No tasks yet' : 'Henüz görev yok',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          language == 'en'
                              ? 'Add tasks to this project'
                              : 'Bu projeye görev ekleyin',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _project.tasks.length,
                    itemBuilder: (context, index) {
                      final task = _project.tasks[index];
                      return RepaintBoundary(
                        child: TaskCard(
                          title: task.title,
                          priority: Priority.values[task.priorityIdx],
                          dueLabel: task.dueLabel,
                          completed: task.completed,
                          currentDueDate: task.dueDate,
                          onToggle: (value) {
                            setState(() {
                              task.completed = value ?? false;
                            });
                            ref.read(projectsProvider.notifier).updateProject(_project);
                          },
                          onTap: () async {
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => EditTaskDialog(
                                initialTitle: task.title,
                                initialPriority: Priority.values[task.priorityIdx],
                                initialDueDate: task.dueDate,
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                task.title = result['title'];
                                task.priorityIdx = result['priorityIdx'];
                                task.dueDate = result['dueDate'];
                                task.dueLabel = result['dueDate'] != null 
                                    ? _formatDateTime(result['dueDate']) 
                                    : null;
                              });
                              ref.read(projectsProvider.notifier).updateProject(_project);
                            }
                          },
                          onSnooze: (newDateTime) {
                            setState(() {
                              task.dueDate = newDateTime;
                              task.dueLabel = _formatDateTime(newDateTime);
                            });
                            ref.read(projectsProvider.notifier).updateProject(_project);
                          },
                          onDelete: () {
                            setState(() {
                              _project.tasks.removeAt(index);
                            });
                            ref.read(projectsProvider.notifier).updateProject(_project);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: Text(language == 'en' ? 'Add Task' : 'Görev Ekle'),
        backgroundColor: color,
      ),
    );
  }

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
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
