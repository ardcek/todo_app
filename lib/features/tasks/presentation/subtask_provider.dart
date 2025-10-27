import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database.dart';
import '../models/subtask_model.dart';

part 'subtask_provider.g.dart';

@riverpod
class SubtaskNotifier extends _$SubtaskNotifier {
  late AppDatabase _db;

  @override
  Future<List<SubtaskModel>> build(int taskId) async {
    _db = await AppDatabase.getInstance();
    return _loadSubtasks(taskId);
  }

  Future<List<SubtaskModel>> _loadSubtasks(int taskId) async {
    final subtasks = await (_db.select(_db.subtasks)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.orderIndex)]))
        .get();

    return subtasks
        .map((s) => SubtaskModel(
              id: s.id,
              taskId: s.taskId,
              title: s.title,
              completed: s.completed,
              orderIndex: s.orderIndex,
              createdAt: s.createdAt,
              updatedAt: s.updatedAt,
            ))
        .toList();
  }

  Future<void> addSubtask(String title) async {
    final now = DateTime.now();
    final currentSubtasks = await future;
    final orderIndex = currentSubtasks.length;

    await _db.into(_db.subtasks).insert(
          SubtasksCompanion.insert(
            taskId: taskId,
            title: title,
            orderIndex: orderIndex,
            createdAt: now,
            updatedAt: now,
          ),
        );

    state = AsyncValue.data(await _loadSubtasks(taskId));
  }

  Future<void> toggleSubtask(int subtaskId) async {
    final subtask = await (_db.select(_db.subtasks)
          ..where((t) => t.id.equals(subtaskId)))
        .getSingle();

    await (_db.update(_db.subtasks)..where((t) => t.id.equals(subtaskId)))
        .write(
      SubtasksCompanion(
        completed: drift.Value(!subtask.completed),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    state = AsyncValue.data(await _loadSubtasks(taskId));
  }

  Future<void> deleteSubtask(int subtaskId) async {
    await (_db.delete(_db.subtasks)..where((t) => t.id.equals(subtaskId))).go();
    state = AsyncValue.data(await _loadSubtasks(taskId));
  }

  Future<void> updateSubtaskTitle(int subtaskId, String newTitle) async {
    await (_db.update(_db.subtasks)..where((t) => t.id.equals(subtaskId)))
        .write(
      SubtasksCompanion(
        title: drift.Value(newTitle),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    state = AsyncValue.data(await _loadSubtasks(taskId));
  }

  Future<void> reorderSubtasks(int oldIndex, int newIndex) async {
    final subtasks = await future;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = subtasks.removeAt(oldIndex);
    subtasks.insert(newIndex, item);

    // Update order indices in database
    for (var i = 0; i < subtasks.length; i++) {
      await (_db.update(_db.subtasks)..where((t) => t.id.equals(subtasks[i].id)))
          .write(
        SubtasksCompanion(
          orderIndex: drift.Value(i),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
    }

    state = AsyncValue.data(await _loadSubtasks(taskId));
  }
}

// Helper provider to get subtask progress
@riverpod
Future<SubtaskProgress> subtaskProgress(SubtaskProgressRef ref, int taskId) async {
  final subtasks = await ref.watch(subtaskNotifierProvider(taskId).future);
  
  if (subtasks.isEmpty) {
    return SubtaskProgress(total: 0, completed: 0, percentage: 0);
  }

  final completed = subtasks.where((s) => s.completed).length;
  final total = subtasks.length;
  final percentage = (completed / total * 100).round();

  return SubtaskProgress(
    total: total,
    completed: completed,
    percentage: percentage,
  );
}

class SubtaskProgress {
  final int total;
  final int completed;
  final int percentage;

  SubtaskProgress({
    required this.total,
    required this.completed,
    required this.percentage,
  });

  bool get hasSubtasks => total > 0;
  bool get allCompleted => total > 0 && completed == total;
}
