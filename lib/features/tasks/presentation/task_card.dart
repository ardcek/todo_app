import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todo_app/features/tasks/presentation/task_options_button.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<Task>? onUpdate;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
    this.onUpdate,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _checkScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCheckboxChanged(bool? value) {
    if (value == true && !widget.task.completed) {
      setState(() => _showCompletion = true);
      _controller.forward().then((_) {
        setState(() => _showCompletion = false);
        widget.onCheckboxChanged(value);
      });
    } else {
      widget.onCheckboxChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: widget.task.priority > 0
                      ? _getPriorityColor(widget.task.priority).withOpacity(0.3)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: ScaleTransition(
                            scale: _checkScale,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.task.completed
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                  width: 2,
                                ),
                                gradient: widget.task.completed
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                              ),
                              child: Checkbox(
                                value: widget.task.completed,
                                onChanged: _handleCheckboxChanged,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide.none,
                                activeColor: Colors.transparent,
                                checkColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.task.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  decoration: widget.task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: widget.task.completed
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (widget.task.note?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.task.note!,
                                  style: TextStyle(
                                    fontSize: 14,
                                  color: widget.task.completed
                                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  decoration: widget.task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.task.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: _getDueDateColor(widget.task.dueDate!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(widget.task.dueDate!),
                                style: TextStyle(
                                  color: _getDueDateColor(widget.task.dueDate!),
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox(),
                        Row(
                          children: [
                            if (widget.task.reminderDate != null) ...[
                              Icon(
                                Icons.notifications,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                            ],
                            _buildPriorityIndicator(widget.task.priority),
                            TaskOptionsButton(
                              onSnooze: widget.task.completed ? null : (duration) {
                                final baseTime = widget.task.dueDate ?? DateTime.now();
                                final newDueDate = baseTime.add(duration);
                                final updatedTask = widget.task.copyWith(
                                  dueDate: newDueDate,
                                  snoozedUntil: newDueDate,
                                  originalDueDate: widget.task.dueDate ?? baseTime,
                                );
                                widget.onUpdate?.call(updatedTask);
                                
                                // Snackbar göster
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      L10n.of(context).taskSnoozed(
                                        widget.task.title,
                                        _formatDate(newDueDate),
                                      ),
                                    ),
                                    action: SnackBarAction(
                                      label: L10n.of(context).undo,
                                      onPressed: () {
                                        // Eski haline geri döndür
                                        widget.onUpdate?.call(widget.task);
                                      },
                                    ),
                                  ),
                                );
                              },
                              onEdit: () {
                                // TODO: Implement edit
                                debugPrint('Edit task');
                              },
                              onDelete: () {
                                // TODO: Implement delete
                                debugPrint('Delete task');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showCompletion)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    final color = _getPriorityColor(priority);
    return Row(
      children: [
        Icon(Icons.flag, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          priority == 3 ? L10n.of(context).highPriority[0] :
          priority == 2 ? L10n.of(context).mediumPriority[0] :
          priority == 1 ? L10n.of(context).lowPriority[0] : '-',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return L10n.of(context).today;
    } else if (dateOnly == tomorrow) {
      return L10n.of(context).tomorrow;
    } else {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF28A745); // Yumuşak yeşil
      case 2:
        return const Color(0xFFFFC107); // Yumuşak sarı
      case 3:
        return const Color(0xFFDC3545); // Yumuşak kırmızı
      default:
        return const Color(0xFF6C757D); // Yumuşak gri
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) {
      return Theme.of(context).colorScheme.error;
    } else if (dueDate.difference(now).inDays <= 1) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  }
}