import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/l10n/l10n.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
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
      children: <Widget>[
        Card(
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Transform.scale(
                        scale: 1.2,
                        child: ScaleTransition(
                          scale: _checkScale,
                          child: Checkbox(
                            value: widget.task.completed,
                            onChanged: _handleCheckboxChanged,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.task.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                decoration: widget.task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: widget.task.completed
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (widget.task.note?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.task.note!,
                                style: TextStyle(
                                  color: widget.task.completed
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                      : Theme.of(context).colorScheme.onSurface,
                                  decoration: widget.task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
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
                    children: <Widget>[
                      if (widget.task.dueDate != null)
                        Row(
                          children: <Widget>[
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
                        children: <Widget>[
                          if (widget.task.reminderDate != null) ...[
                            Icon(
                              Icons.notifications,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                          ],
                          _buildPriorityIndicator(widget.task.priority),
                        ],
                      ),
                    ],
                  ),
                ],
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
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
      children: <Widget>[
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
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
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