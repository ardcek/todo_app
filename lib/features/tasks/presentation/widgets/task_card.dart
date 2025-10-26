import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/timer/presentation/timer_controller.dart';

enum Priority { low, medium, high }

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.priority,
    required this.dueLabel,
    required this.completed,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.onSnooze,
    this.currentDueDate,
  });

  final String title;
  final Priority priority;
  final String? dueLabel;
  final bool completed;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(DateTime)? onSnooze;
  final DateTime? currentDueDate;

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

  String get priorityLabel => switch (priority) {
        Priority.low => 'Low',
        Priority.medium => 'Med',
        Priority.high => 'High',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

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
                            label: Text(priorityLabel),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide(color: _priorityBorder(scheme)),
                          ),
                        ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Timer: $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Focus timer başlat'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(timerProvider.notifier).startTimer(const Duration(minutes: 15), title);
                  },
                  child: const Text('15m'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(timerProvider.notifier).startTimer(const Duration(minutes: 25), title);
                  },
                  child: const Text('25m'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(timerProvider.notifier).startTimer(const Duration(minutes: 45), title);
                  },
                  child: const Text('45m'),
                ),
              ],
            ),
          ],
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



