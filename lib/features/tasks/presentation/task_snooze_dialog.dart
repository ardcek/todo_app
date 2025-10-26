import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/config/language_controller.dart';

class TaskSnoozeDialog extends ConsumerWidget {
  const TaskSnoozeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageControllerProvider);
    final theme = Theme.of(context);
    
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  language == 'en' ? 'Snooze Task' : 'Görevi Ertele',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Hızlı erteleme seçenekleri
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickSnoozeChip(
                  icon: Icons.timer,
                  label: '1 ${language == 'en' ? 'hour' : 'saat'}',
                  onTap: () => _handleSnooze(context, Duration(hours: 1)),
                ),
                _QuickSnoozeChip(
                  icon: Icons.timer,
                  label: '4 ${language == 'en' ? 'hours' : 'saat'}',
                  onTap: () => _handleSnooze(context, Duration(hours: 4)),
                ),
                _QuickSnoozeChip(
                  icon: Icons.wb_sunny,
                  label: language == 'en' ? 'Tomorrow 9:00' : 'Yarın 09:00',
                  onTap: () => _handleSnooze(
                    context,
                    _getTomorrowMorning(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Özel tarih seçimi
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(language == 'en' ? 'Pick Date/Time' : 'Tarih/Saat Seç'),
              onPressed: () => _showDateTimePicker(context),
            ),
            const SizedBox(height: 8),
            // İptal butonu
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(language == 'en' ? 'Cancel' : 'İptal'),
            ),
          ],
        ),
      ),
    );
  }

  Duration _getTomorrowMorning() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);
    return tomorrow.difference(now);
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null && context.mounted) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        Navigator.pop(context, selectedDateTime.difference(now));
      }
    }
  }

  void _handleSnooze(BuildContext context, Duration duration) {
    Navigator.pop(context, duration);
  }
}

class _QuickSnoozeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickSnoozeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}