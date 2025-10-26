import 'package:flutter/material.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  int _dateIdx = 0;
  int _priorityIdx = 1; // 0 low,1 med,2 high
  DateTime? _pickedDateTime;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                autofocus: true,
                controller: _titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Görev başlığı'),
                onSubmitted: (_) => _onSave(),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.event),
                label: Text(_pickedDateTime == null
                    ? 'Tarih/Saat seç'
                    : _formatDateTime(_pickedDateTime!)),
              ),
              if (_pickedDateTime != null)
                TextButton.icon(
                  onPressed: () => setState(() => _pickedDateTime = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Tarihi temizle'),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in ['Düşük', 'Orta', 'Yüksek'].indexed)
                    ChoiceChip(
                      label: Text(e.$2),
                      selected: _priorityIdx == e.$1,
                      onSelected: (_) => setState(() => _priorityIdx = e.$1),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onSave,
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  void _onSave() {
    final title = _titleController.text.trim();
    Navigator.of(context).pop({
      'title': title,
      'dateTime': _pickedDateTime,
      'priority': _priorityIdx,
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _pickedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }
}


