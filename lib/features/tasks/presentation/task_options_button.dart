import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/features/tasks/presentation/task_snooze_dialog.dart';

class TaskOptionsButton extends ConsumerWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(Duration)? onSnooze;

  const TaskOptionsButton({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onSnooze,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageControllerProvider);
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        if (onSnooze != null)
          PopupMenuItem(
            value: 'snooze',
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(language == 'en' ? 'Snooze' : 'Ertele'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: Text(language == 'en' ? 'Edit' : 'Düzenle'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(language == 'en' ? 'Delete' : 'Sil'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'snooze':
            final result = await showDialog<Duration>(
              context: context,
              builder: (context) => const TaskSnoozeDialog(),
            );
            if (result != null) {
              onSnooze?.call(result);
            }
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
    );
  }
}