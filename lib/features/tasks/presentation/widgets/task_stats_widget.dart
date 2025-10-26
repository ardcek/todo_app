import 'package:flutter/material.dart';

class TaskStatsWidget extends StatelessWidget {
  const TaskStatsWidget({
    super.key,
    required this.completed,
    required this.remaining,
    required this.progress,
  });

  final int completed;
  final int remaining;
  final double progress; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.check_circle_outline,
            value: completed.toString(),
            label: 'Completed',
            color: colorScheme.primary,
            iconColor: Colors.green,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
          _StatItem(
            icon: Icons.radio_button_unchecked,
            value: remaining.toString(),
            label: 'Remaining',
            color: colorScheme.secondary,
            iconColor: Colors.orange,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
          _StatItem(
            icon: Icons.analytics_outlined,
            value: '${(progress * 100).toInt()}%',
            label: 'Progress',
            color: colorScheme.tertiary,
            iconColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
