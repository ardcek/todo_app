import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required int id,
    required String title,
    String? note,
    DateTime? dueDate,
    DateTime? reminderDate,
    @Default(0) int priority,
    String? project,
    @Default(false) bool completed,
    required int orderIndex,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    DateTime? snoozedUntil,
    DateTime? originalDueDate,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}