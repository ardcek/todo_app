import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/timer/presentation/timer_notification_service.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier(this._ref) : super(TimerState());

  final Ref _ref;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void startTimer(Duration duration, String taskTitle) async {
    state = state.copyWith(
      isRunning: true,
      remainingTime: duration,
      taskTitle: taskTitle,
      totalDuration: duration,
    );
    
    // Show notification
    final notificationService = _ref.read(timerNotificationServiceProvider);
    await notificationService.showTimerNotification(
      title: taskTitle,
      remainingTime: state.formattedTime,
      isRunning: true,
      progress: state.progress,
    );
    
    _tick();
  }

  void pauseTimer() async {
    state = state.copyWith(isRunning: false);
    
    // Update notification
    final notificationService = _ref.read(timerNotificationServiceProvider);
    await notificationService.showTimerNotification(
      title: state.taskTitle,
      remainingTime: state.formattedTime,
      isRunning: false,
      progress: state.progress,
    );
  }

  void resumeTimer() async {
    state = state.copyWith(isRunning: true);
    
    // Update notification
    final notificationService = _ref.read(timerNotificationServiceProvider);
    await notificationService.showTimerNotification(
      title: state.taskTitle,
      remainingTime: state.formattedTime,
      isRunning: true,
      progress: state.progress,
    );
    
    _tick();
  }

  void stopTimer() async {
    state = TimerState();
    
    // Cancel notification
    final notificationService = _ref.read(timerNotificationServiceProvider);
    await notificationService.cancelTimerNotification();
  }

  void _tick() async {
    if (!state.isRunning) return;
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (!state.isRunning) return;
    
    final newTime = state.remainingTime - const Duration(seconds: 1);
    if (newTime <= Duration.zero) {
      state = state.copyWith(
        isRunning: false,
        remainingTime: Duration.zero,
        isCompleted: true,
      );
      
      // Play alarm sound using audioplayers
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setVolume(1.0);
        // Use a notification sound URL or local asset
        await _audioPlayer.play(UrlSource(
          'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        ));
      } catch (e) {
        debugPrint('Error playing alarm sound: $e');
      }
      
      // Show completion notification
      final notificationService = _ref.read(timerNotificationServiceProvider);
      await notificationService.cancelTimerNotification();
      await notificationService.showTimerCompleteNotification(state.taskTitle);
      return;
    }
    
    state = state.copyWith(remainingTime: newTime);
    
    // Update notification every second for smooth progress
    final notificationService = _ref.read(timerNotificationServiceProvider);
    await notificationService.showTimerNotification(
      title: state.taskTitle,
      remainingTime: state.formattedTime,
      isRunning: true,
      progress: state.progress,
    );
    
    _tick();
  }
}

class TimerState {
  final bool isRunning;
  final Duration remainingTime;
  final Duration totalDuration;
  final String taskTitle;
  final bool isCompleted;

  TimerState({
    this.isRunning = false,
    this.remainingTime = Duration.zero,
    this.totalDuration = Duration.zero,
    this.taskTitle = '',
    this.isCompleted = false,
  });

  TimerState copyWith({
    bool? isRunning,
    Duration? remainingTime,
    Duration? totalDuration,
    String? taskTitle,
    bool? isCompleted,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      remainingTime: remainingTime ?? this.remainingTime,
      totalDuration: totalDuration ?? this.totalDuration,
      taskTitle: taskTitle ?? this.taskTitle,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progress {
    if (totalDuration == Duration.zero) return 0.0;
    return 1.0 - (remainingTime.inSeconds / totalDuration.inSeconds);
  }

  String get formattedTime {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    final seconds = remainingTime.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) => TimerNotifier(ref));
