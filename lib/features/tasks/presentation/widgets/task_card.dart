import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/timer/presentation/timer_controller.dart';
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/features/tasks/presentation/subtask_provider.dart';

enum Priority { low, medium, high }

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.taskId,
    required this.title,
    required this.priority,
    required this.dueLabel,
    required this.completed,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.onSnooze,
    this.currentDueDate,
    this.notes,
  });

  final int taskId;
  final String title;
  final Priority priority;
  final String? dueLabel;
  final bool completed;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(DateTime)? onSnooze;
  final DateTime? currentDueDate;
  final String? notes;

  Color _priorityBorder(ColorScheme scheme) {
    switch (priority) {
      case Priority.high:
        return scheme.error;
      case Priority.medium:
        return scheme.primary;
      case Priority.low:
        return scheme.outlineVariant;
    }
  }

  String _priorityLabel(String language) => switch (priority) {
        Priority.low => language == 'en' ? 'Low' : 'Düşük',
        Priority.medium => language == 'en' ? 'Med' : 'Orta',
        Priority.high => language == 'en' ? 'High' : 'Yüksek',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final language = ref.watch(languageControllerProvider);
    final subtaskProgress = ref.watch(subtaskProgressProvider(taskId));

    return Dismissible(
      key: ValueKey('$title-$priority-$dueLabel'),
      background: _buildDismissBackground(context, Icons.snooze, 'Ertele'),
      secondaryBackground: _buildDismissBackground(context, Icons.delete_outline, 'Sil', isSecondary: true),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Snooze functionality
          final newDateTime = await _showSnoozeDialog(context);
          if (newDateTime != null) {
            onSnooze?.call(newDateTime);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Görev ertelendi: ${_formatDateTime(newDateTime)}'),
                action: SnackBarAction(label: 'Geri al', onPressed: () {}),
              ),
            );
          }
          return false; // do not remove
        } else {
          onDelete();
          return false; // signal action, do not auto-remove
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _priorityBorder(scheme), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: 'Tamamlandı',
                  child: Checkbox(value: completed, onChanged: onToggle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: completed ? TextDecoration.lineThrough : null,
                              color: completed ? Theme.of(context).colorScheme.outline : null,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (dueLabel != null)
                            Chip(
                              label: Text(dueLabel!),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(color: scheme.outlineVariant),
                            ),
                          Chip(
                            label: Text(_priorityLabel(language)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide(color: _priorityBorder(scheme)),
                          ),
                          if (notes != null && notes!.isNotEmpty)
                            Chip(
                              avatar: Icon(
                                Icons.notes_rounded,
                                size: 16,
                                color: scheme.tertiary,
                              ),
                              label: Text(
                                language == 'en' ? 'Note' : 'Not',
                                style: TextStyle(color: scheme.tertiary),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(color: scheme.tertiary.withOpacity(0.5)),
                              backgroundColor: scheme.tertiaryContainer.withOpacity(0.3),
                            ),
                        ],
                      ),
                      // Subtask Progress
                      subtaskProgress.when(
                        data: (progress) {
                          if (progress.total == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 14,
                                  color: scheme.primary.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${progress.completed}/${progress.total}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress.percentage / 100,
                                      minHeight: 6,
                                      backgroundColor: scheme.surfaceVariant,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress.percentage == 100
                                            ? Colors.green
                                            : scheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${progress.percentage.toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Daha fazla',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onTap();
                        break;
                      case 'timer':
                        _showTimerDialog(context, ref);
                        break;
                      case 'snooze':
                        _showSnoozeDialog(context).then((newDateTime) {
                          if (newDateTime != null) {
                            onSnooze?.call(newDateTime);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Görev ertelendi: ${_formatDateTime(newDateTime)}'),
                                action: SnackBarAction(label: 'Geri al', onPressed: () {}),
                              ),
                            );
                          }
                        });
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                    PopupMenuItem(value: 'timer', child: Text('Timer Başlat')),
                    PopupMenuItem(value: 'snooze', child: Text('Ertele')),
                    PopupMenuItem(value: 'delete', child: Text('Sil')),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTimerDialog(BuildContext context, WidgetRef ref) {
    final language = ref.read(languageControllerProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.timer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(language == 'en' ? 'Start focus timer' : 'Odaklanma zamanlayıcısı başlat'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _TimerButton(
                  label: '15m',
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(timerProvider.notifier).startTimer(const Duration(minutes: 15), title);
                  },
                ),
                _TimerButton(
                  label: '25m',
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(timerProvider.notifier).startTimer(const Duration(minutes: 25), title);
                  },
                ),
                _TimerButton(
                  label: '45m',
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(timerProvider.notifier).startTimer(const Duration(minutes: 45), title);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showCustomTimerDialog(context, ref);
              },
              icon: const Icon(Icons.edit),
              label: Text(language == 'en' ? 'Custom' : 'Özel'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language == 'en' ? 'Cancel' : 'İptal'),
          ),
        ],
      ),
    );
  }

  void _showCustomTimerDialog(BuildContext context, WidgetRef ref) {
    final language = ref.read(languageControllerProvider);
    final hoursController = TextEditingController(text: '0');
    final minutesController = TextEditingController(text: '25');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language == 'en' ? 'Custom Timer' : 'Özel Zamanlayıcı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: language == 'en' ? 'Hours (0-23)' : 'Saat (0-23)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: language == 'en' ? 'Minutes (0-59)' : 'Dakika (0-59)',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language == 'en' ? 'Cancel' : 'İptal'),
          ),
          FilledButton(
            onPressed: () {
              final hours = int.tryParse(hoursController.text) ?? 0;
              final minutes = int.tryParse(minutesController.text) ?? 0;
              
              if (hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
                if (hours == 0 && minutes == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        language == 'en' 
                            ? 'Please enter a valid duration'
                            : 'Lütfen geçerli bir süre girin',
                      ),
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                final duration = Duration(hours: hours, minutes: minutes);
                ref.read(timerProvider.notifier).startTimer(duration, title);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      language == 'en'
                          ? 'Invalid time range'
                          : 'Geçersiz zaman aralığı',
                    ),
                  ),
                );
              }
            },
            child: Text(language == 'en' ? 'Start' : 'Başlat'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _showSnoozeDialog(BuildContext context) async {
    return await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.schedule),
            SizedBox(width: 8),
            Text('Görevi Ertele'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Hızlı seçenekler:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SnoozeButton(
                    label: '1 Saat',
                    onPressed: () {
                      final baseTime = currentDueDate ?? DateTime.now();
                      Navigator.pop(context, baseTime.add(const Duration(hours: 1)));
                    },
                  ),
                  _SnoozeButton(
                    label: '4 Saat',
                    onPressed: () {
                      final baseTime = currentDueDate ?? DateTime.now();
                      Navigator.pop(context, baseTime.add(const Duration(hours: 4)));
                    },
                  ),
                  _SnoozeButton(
                    label: 'Yarın 09:00',
                    onPressed: () {
                      final now = DateTime.now();
                      final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);
                      Navigator.pop(context, tomorrow);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(hours: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null && context.mounted) {
                      final dateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      Navigator.pop(context, dateTime);
                    }
                  }
                },
                icon: const Icon(Icons.event),
                label: const Text('Özel Tarih/Saat'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
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

  Widget _buildDismissBackground(BuildContext context, IconData icon, String label, {bool isSecondary = false}) {
    final scheme = Theme.of(context).colorScheme;
    final color = isSecondary ? scheme.errorContainer : scheme.secondaryContainer;
    final onColor = isSecondary ? scheme.onErrorContainer : scheme.onSecondaryContainer;
    return Container(
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSecondary) ...[
            Icon(icon, color: onColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: onColor)),
          ] else ...[
            Text(label, style: TextStyle(color: onColor)),
            const SizedBox(width: 8),
            Icon(icon, color: onColor),
          ]
        ],
      ),
    );
  }
}

class _SnoozeButton extends StatelessWidget {
  const _SnoozeButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}






