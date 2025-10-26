import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerNotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showTimerNotification({
    required String title,
    required String remainingTime,
    required bool isRunning,
    required double progress,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Timer notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      showProgress: true,
      maxProgress: 100,
      progress: (progress * 100).toInt(),
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      isRunning ? '⏱️ Timer Çalışıyor' : '⏸️ Timer Duraklatıldı',
      '$title - Kalan: $remainingTime',
      details,
    );
  }

  Future<void> showTimerCompleteNotification(String title) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'timer_complete_channel',
      'Timer Tamamlandı',
      channelDescription: 'Timer completion notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      2,
      '✅ Timer Tamamlandı!',
      title,
      details,
    );
  }

  Future<void> cancelTimerNotification() async {
    await _notifications.cancel(1);
  }
}

final timerNotificationServiceProvider = Provider((ref) => TimerNotificationService());
