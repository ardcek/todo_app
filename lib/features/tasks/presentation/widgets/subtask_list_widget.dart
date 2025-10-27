import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/language_controller.dart';
import '../../models/subtask_model.dart';
import '../subtask_provider.dart';

class SubtaskListWidget extends ConsumerStatefulWidget {
  final int taskId;

  const SubtaskListWidget({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<SubtaskListWidget> createState() => _SubtaskListWidgetState();
}

class _SubtaskListWidgetState extends ConsumerState<SubtaskListWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    ref.read(subtaskNotifierProvider(widget.taskId).notifier).addSubtask(title);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final subtasksAsync = ref.watch(subtaskNotifierProvider(widget.taskId));
    final language = ref.watch(languageControllerProvider);
    final isTurkish = language == 'tr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isTurkish ? 'Alt Görevler' : 'Subtasks',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Spacer(),
              subtasksAsync.whenOrNull(
                data: (subtasks) {
                  if (subtasks.isEmpty) return const SizedBox.shrink();
                  final completed = subtasks.where((s) => s.completed).length;
                  return Text(
                    '$completed/${subtasks.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                },
              ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),

        // Subtask List
        subtasksAsync.when(
          data: (subtasks) => Column(
            mainAxisSize: MainAxisSize.min,
            children: subtasks.map((subtask) {
              return _SubtaskItem(
                key: ValueKey(subtask.id),
                subtask: subtask,
                taskId: widget.taskId,
              );
            }).toList(),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),

        // Add Subtask Field
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: isTurkish
                        ? 'Alt görev ekle...'
                        : 'Add subtask...',
                    prefixIcon: const Icon(Icons.add_rounded, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addSubtask,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(isTurkish ? 'Ekle' : 'Add'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubtaskItem extends ConsumerStatefulWidget {
  final SubtaskModel subtask;
  final int taskId;

  const _SubtaskItem({
    super.key,
    required this.subtask,
    required this.taskId,
  });

  @override
  ConsumerState<_SubtaskItem> createState() => _SubtaskItemState();
}

class _SubtaskItemState extends ConsumerState<_SubtaskItem> {
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.subtask.title);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _saveEdit() {
    final newTitle = _editController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.subtask.title) {
      ref
          .read(subtaskNotifierProvider(widget.taskId).notifier)
          .updateSubtaskTitle(widget.subtask.id, newTitle);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageControllerProvider);
    final isTurkish = language == 'tr';

    return Dismissible(
      key: ValueKey(widget.subtask.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(isTurkish ? 'Alt Görevi Sil?' : 'Delete Subtask?'),
                content: Text(
                  isTurkish
                      ? 'Bu alt görevi silmek istediğinizden emin misiniz?'
                      : 'Are you sure you want to delete this subtask?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(isTurkish ? 'İptal' : 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: Text(isTurkish ? 'Sil' : 'Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        ref
            .read(subtaskNotifierProvider(widget.taskId).notifier)
            .deleteSubtask(widget.subtask.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                index: 0,
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              Checkbox(
                value: widget.subtask.completed,
                onChanged: (_) {
                  ref
                      .read(subtaskNotifierProvider(widget.taskId).notifier)
                      .toggleSubtask(widget.subtask.id);
                },
              ),
            ],
          ),
          title: _isEditing
              ? TextField(
                  controller: _editController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _saveEdit(),
                )
              : Text(
                  widget.subtask.title,
                  style: TextStyle(
                    decoration: widget.subtask.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: widget.subtask.completed
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
          trailing: _isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_rounded),
                      onPressed: _saveEdit,
                      tooltip: isTurkish ? 'Kaydet' : 'Save',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _editController.text = widget.subtask.title;
                        setState(() => _isEditing = false);
                      },
                      tooltip: isTurkish ? 'İptal' : 'Cancel',
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: isTurkish ? 'Düzenle' : 'Edit',
                ),
        ),
      ),
    );
  }
}
