import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/tasks/data/task_repository.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/l10n/l10n.dart';

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

    try {
      final repository = ref.read(taskRepositoryProvider);
      
      if (widget.task == null) {
        await repository.createTask(
          title: _titleController.text,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          dueDate: _dueDate,
          reminderDate: _reminderDate,
          priority: _priority,
          project: _project?.isNotEmpty == true ? _project : null,
        );
      } else {
        await repository.updateTask(widget.task!.copyWith(
          title: _titleController.text,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          dueDate: _dueDate,
          reminderDate: _reminderDate,
          priority: _priority,
          project: _project?.isNotEmpty == true ? _project : null,
        ));
      }

      if (mounted && context.mounted) {
        context.go('/');
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving task: $e\n$stackTrace');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev kaydedilirken bir hata oluştu: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: _save,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.task == null ? l10n.addTask : l10n.editTask,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
          tooltip: l10n.cancel,
        ),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            tooltip: l10n.save,
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
                labelText: l10n.taskTitle,
                hintText: l10n.taskTitle,
                prefixIcon: const Icon(Icons.check_circle_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                if (value.length < 3) {
                  return 'Başlık en az 3 karakter olmalı';
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
                labelText: l10n.taskDescription,
                hintText: 'Bu görev hakkında daha fazla detay ekleyin...',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            _buildDateTimeField(
              title: l10n.taskDueDate,
              value: _dueDate,
              icon: Icons.event,
              color: _dueDate?.isBefore(DateTime.now()) ?? false
                  ? Theme.of(context).colorScheme.error
                  : null,
              onTap: () => _selectDate(context, false),
              onClear: () => setState(() => _dueDate = null),
            ),
            const SizedBox(height: 16),
            _buildDateTimeField(
              title: l10n.reminder,
              value: _reminderDate,
              icon: Icons.notifications,
              color: _reminderDate?.isBefore(DateTime.now()) ?? false
                  ? Theme.of(context).colorScheme.error
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
                labelText: l10n.taskProject,
                  hintText: 'Görevi bir projeye ekle',
                  prefixIcon: const Icon(Icons.folder_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  helperText: l10n.projectHelperText,
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
      dateStr = L10n.of(context).today;
    } else if (dateOnly == tomorrow) {
      dateStr = L10n.of(context).tomorrow;
    } else {
      dateStr = '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    }
    
    return '$dateStr saat ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDateTimeField({
    required String title,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
    Color? color,
  }) {
    final l10n = L10n.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value != null ? _formatDateTime(value) : l10n.notSet,
                        style: TextStyle(
                          color: color ?? Theme.of(context).colorScheme.onSurface,
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
                    tooltip: l10n.clearField(title),
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            L10n.of(context).taskPriority,
            style: const TextStyle(
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
                label: '-',
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                value: 1,
                label: L10n.of(context).lowPriority,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                value: 2,
                label: L10n.of(context).mediumPriority,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                value: 3,
                label: L10n.of(context).highPriority,
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [],
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