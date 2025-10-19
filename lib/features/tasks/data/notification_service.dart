import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/models/task.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    // TODO: Implement when notification package is fixed
    _isInitialized = true;
  }

  Future<void> scheduleDueNotification(Task task) async {
    if (!_isInitialized) await initialize();
    // TODO: Implement when notification package is fixed
  }

  Future<void> cancelNotification(Task task) async {
    if (!_isInitialized) await initialize();
    // TODO: Implement when notification package is fixed
  }
}