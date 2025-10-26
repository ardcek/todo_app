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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language == 'en' ? 'Snooze Task' : 'Görevi Ertele',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Hızlı erteleme seçenekleri
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickSnoozeChip(
                  icon: Icons.access_time_rounded,
                  label: '1 ${language == 'en' ? 'hour' : 'saat'}',
                  onTap: () => _handleSnooze(context, Duration(hours: 1)),
                ),
                _QuickSnoozeChip(
                  icon: Icons.hourglass_bottom_rounded,
                  label: '4 ${language == 'en' ? 'hours' : 'saat'}',
                  onTap: () => _handleSnooze(context, Duration(hours: 4)),
                ),
                _QuickSnoozeChip(
                  icon: Icons.wb_sunny_rounded,
                  label: language == 'en' ? 'Tomorrow 9:00' : 'Yarın 09:00',
                  onTap: () => _handleSnooze(
                    context,
                    _getTomorrowMorning(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 20),
            // Özel tarih seçimi
            FilledButton.tonalIcon(
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(language == 'en' ? 'Pick Date/Time' : 'Tarih/Saat Seç'),
              onPressed: () => _showDateTimePicker(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            // İptal butonu
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}