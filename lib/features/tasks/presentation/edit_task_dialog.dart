import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:todo_app/core/config/language_controller.dart';

class EditTaskDialog extends ConsumerStatefulWidget {
  const EditTaskDialog({
    super.key,
    required this.initialTitle,
    required this.initialPriority,
    this.initialDueDate,
  });

  final String initialTitle;
  final Priority initialPriority;
  final DateTime? initialDueDate;

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  late TextEditingController _titleController;
  late int _priorityIdx;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _priorityIdx = widget.initialPriority.index;
    _dueDate = widget.initialDueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageControllerProvider);
    
    return AlertDialog(
      title: Text(language == 'en' ? 'Edit Task' : 'Görevi Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: language == 'en' ? 'Title' : 'Başlık',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              language == 'en' ? 'Priority' : 'Öncelik',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(language == 'en' ? 'Low' : 'Düşük'),
                  selected: _priorityIdx == 0,
                  onSelected: (_) => setState(() => _priorityIdx = 0),
                ),
                ChoiceChip(
                  label: Text(language == 'en' ? 'Medium' : 'Orta'),
                  selected: _priorityIdx == 1,
                  onSelected: (_) => setState(() => _priorityIdx = 1),
                ),
                ChoiceChip(
                  label: Text(language == 'en' ? 'High' : 'Yüksek'),
                  selected: _priorityIdx == 2,
                  onSelected: (_) => setState(() => _priorityIdx = 2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.event),
              label: Text(_dueDate == null
                  ? (language == 'en' ? 'Select date/time' : 'Tarih/Saat seç')
                  : _formatDateTime(_dueDate!)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _dueDate = null),
                icon: const Icon(Icons.clear),
                label: Text(language == 'en' ? 'Clear date' : 'Tarihi temizle'),
              ),
            ],
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
            Navigator.pop(context, {
              'title': _titleController.text.trim(),
              'priority': _priorityIdx,
              'dueDate': _dueDate,
            });
          },
          child: Text(language == 'en' ? 'Save' : 'Kaydet'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    
    if (dateOnly == today) return 'Bugün $time';
    final tomorrow = today.add(const Duration(days: 1));
    if (dateOnly == tomorrow) return 'Yarın $time';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} $time';
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? now),
    );
    if (time == null || !mounted) return;
    
    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }
}
