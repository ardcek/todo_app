import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/features/tasks/data/task_repository.dart';
import 'package:todo_app/features/tasks/models/task.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({
    super.key,
    this.task,
  });

  final Task? task;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  int _priority = 0;
  String? _project;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _noteController = TextEditingController(text: widget.task?.note);
    _dueDate = widget.task?.dueDate;
    _reminderDate = widget.task?.reminderDate;
    _priority = widget.task?.priority ?? 0;
    _project = widget.task?.project;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isReminder) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isReminder) {
        _reminderDate = dateTime;
      } else {
        _dueDate = dateTime;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(taskRepositoryProvider);

    try {
      if (widget.task == null) {
        await repository.createTask(_titleController.text);
      } else {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          note: _noteController.text,
          dueDate: _dueDate,
          reminderDate: _reminderDate,
          priority: _priority,
          project: _project,
        );
        await repository.updateTask(updatedTask);
      }

      if (mounted) {
        if (context.mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            tooltip: 'Save task',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'What needs to be done?',
                prefixIcon: const Icon(Icons.task_alt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              autofocus: widget.task == null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Add more details about this task...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            _buildDateTimeField(
              title: 'Due Date',
              value: _dueDate,
              icon: Icons.event,
              color: _dueDate?.isBefore(DateTime.now()) ?? false
                  ? AppTheme.errorColor
                  : null,
              onTap: () => _selectDate(context, false),
              onClear: () => setState(() => _dueDate = null),
            ),
            const SizedBox(height: 16),
            _buildDateTimeField(
              title: 'Reminder',
              value: _reminderDate,
              icon: Icons.notifications,
              color: _reminderDate?.isBefore(DateTime.now()) ?? false
                  ? AppTheme.errorColor
                  : null,
              onTap: () => _selectDate(context, true),
              onClear: () => setState(() => _reminderDate = null),
            ),
            const SizedBox(height: 24),
            _buildPrioritySelector(),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _project,
              decoration: InputDecoration(
                labelText: 'Project',
                hintText: 'Organize tasks by project (optional)',
                prefixIcon: const Icon(Icons.folder),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _project = value.isEmpty ? null : value;
                });
              },
              textInputAction: TextInputAction.done,
              onEditingComplete: _save,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      dateStr = 'Today';
    } else if (dateOnly == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    }
    
    return '$dateStr at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDateTimeField({
    required String title,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value != null ? _formatDateTime(value) : 'Not set',
                        style: TextStyle(
                          color: color ?? AppTheme.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (value != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                    tooltip: 'Clear $title',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Priority',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildPriorityOption(
                value: 0,
                label: 'None',
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                value: 1,
                label: 'Low',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                value: 2,
                label: 'Medium',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                value: 3,
                label: 'High',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption({
    required int value,
    required String label,
    required Color color,
  }) {
    final isSelected = _priority == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _priority = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                Icons.flag,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}