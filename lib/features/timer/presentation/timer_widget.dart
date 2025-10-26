import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/timer/presentation/timer_controller.dart';
import 'package:todo_app/core/config/language_controller.dart';

class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final language = ref.watch(languageControllerProvider);
    
    if (!timer.isRunning && timer.remainingTime == Duration.zero) {
      return _buildStartTimer(context, ref);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timer.taskTitle.isNotEmpty 
                        ? timer.taskTitle 
                        : (language == 'en' ? 'Timer' : 'Zamanlayıcı'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref.read(timerProvider.notifier).stopTimer(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              timer.formattedTime,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: timer.isCompleted 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: timer.progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                timer.isCompleted 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (timer.isRunning)
                  ElevatedButton.icon(
                    onPressed: () => ref.read(timerProvider.notifier).pauseTimer(),
                    icon: const Icon(Icons.pause),
                    label: Text(language == 'en' ? 'Pause' : 'Duraklat'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => ref.read(timerProvider.notifier).resumeTimer(),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(language == 'en' ? 'Resume' : 'Devam'),
                  ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(timerProvider.notifier).stopTimer(),
                  icon: const Icon(Icons.stop),
                  label: Text(language == 'en' ? 'Stop' : 'Durdur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
            if (timer.isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  language == 'en' ? 'Timer completed!' : 'Zamanlayıcı tamamlandı!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartTimer(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageControllerProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  language == 'en' ? 'Focus Timer' : 'Odaklanma Zamanlayıcısı',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimerButton(context, ref, '15m', const Duration(minutes: 15)),
                _buildTimerButton(context, ref, '25m', const Duration(minutes: 25)),
                _buildTimerButton(context, ref, '45m', const Duration(minutes: 45)),
                _buildTimerButton(context, ref, '1h', const Duration(hours: 1)),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showCustomTimerDialog(context, ref),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(language == 'en' ? 'Custom' : 'Özel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerButton(BuildContext context, WidgetRef ref, String label, Duration duration) {
    return ElevatedButton(
      onPressed: () => ref.read(timerProvider.notifier).startTimer(duration, 'Focus Session'),
      child: Text(label),
    );
  }

  void _showCustomTimerDialog(BuildContext context, WidgetRef ref) {
    final language = ref.read(languageControllerProvider);
    final hoursController = TextEditingController(text: '0');
    final minutesController = TextEditingController(text: '25');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language == 'en' ? 'Custom Timer' : 'Özel Zamanlayıcı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: language == 'en' ? 'Hours' : 'Saat',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: language == 'en' ? 'Minutes' : 'Dakika',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.schedule),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language == 'en' ? 'Cancel' : 'İptal'),
          ),
          FilledButton(
            onPressed: () {
              final hours = int.tryParse(hoursController.text) ?? 0;
              final minutes = int.tryParse(minutesController.text) ?? 0;
              
              if (hours == 0 && minutes == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      language == 'en' 
                          ? 'Please enter a valid duration' 
                          : 'Lütfen geçerli bir süre girin',
                    ),
                  ),
                );
                return;
              }
              
              if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      language == 'en' 
                          ? 'Invalid time range' 
                          : 'Geçersiz zaman aralığı',
                    ),
                  ),
                );
                return;
              }
              
              final duration = Duration(hours: hours, minutes: minutes);
              ref.read(timerProvider.notifier).startTimer(duration, 'Focus Session');
              Navigator.pop(context);
            },
            child: Text(language == 'en' ? 'Start' : 'Başlat'),
          ),
        ],
      ),
    );
  }
}

