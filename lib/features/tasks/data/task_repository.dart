import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/core/database/database.dart';
import 'package:todo_app/features/tasks/data/notification_service.dart';
import 'package:todo_app/features/tasks/models/task.dart' as task_model;

part 'task_repository.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return TaskRepository(ref.watch(appDatabaseProvider.future), ref);
}

@riverpod
Future<AppDatabase> appDatabase(AppDatabaseRef ref) async {
  return await AppDatabase.getInstance();
}

class TaskRepository {
  TaskRepository(this._db, this.ref) {
    debugPrint('Created TaskRepository with database: $_db');
  }

  final Future<AppDatabase> _db;
  final TaskRepositoryRef ref;

  Future<List<task_model.Task>> getAllTasks() async {
    try {
      final db = await _db;
      final tasks = await (db.select(db.tasks)
        ..orderBy([
          (t) => OrderingTerm(expression: t.orderIndex),
        ]))
        .get();
      
      debugPrint('Retrieved ${tasks.length} tasks from database');
      return tasks.map((task) => task_model.Task(
        id: task.id,
        title: task.title,
        note: task.note,
        dueDate: task.dueDate,
        reminderDate: task.reminderDate,
        priority: task.priority,
        project: task.project,
        completed: task.completed,
        orderIndex: task.orderIndex,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        deletedAt: task.deletedAt,
      )).toList();
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      return [];
    }
  }

  Future<task_model.Task> createTask({
    required String title,
    String? note,
    DateTime? dueDate,
    DateTime? reminderDate,
    int priority = 0,
    String? project,
  }) async {
    try {
      debugPrint('Creating new task with title: $title');
      final db = await _db;
      debugPrint('Database connection established');
      
      final now = DateTime.now();
      final maxOrderIndexQuery = await (db.select(db.tasks)
            ..orderBy([(t) => OrderingTerm.desc(t.orderIndex)])
            ..limit(1))
          .map((t) => t.orderIndex)
          .getSingleOrNull();

      final maxOrderIndex = maxOrderIndexQuery ?? 0;
      debugPrint('Current max order index: $maxOrderIndex');

      final companion = TasksCompanion.insert(
        title: title,
        note: Value(note),
        dueDate: Value(dueDate),
        reminderDate: Value(reminderDate),
        priority: Value(priority),
        project: Value(project),
        orderIndex: maxOrderIndex + 1,
        createdAt: now,
        updatedAt: now,
      );
      debugPrint('Preparing to insert task with data: $companion');

      final taskId = await db.into(db.tasks).insert(companion);

      final task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
          
      final newTask = task_model.Task(
        id: task.id,
        title: task.title,
        note: task.note,
        dueDate: task.dueDate,
        reminderDate: task.reminderDate,
        priority: task.priority,
        project: task.project,
        completed: task.completed,
        orderIndex: task.orderIndex,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        deletedAt: task.deletedAt,
      );

      if (task.dueDate != null) {
        try {
          await ref.read(notificationServiceProvider).scheduleDueNotification(newTask);
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }
      }

      return newTask;
    } catch (e) {
      debugPrint('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(task_model.Task task) async {
    try {
      final db = await _db;
      await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
            TasksCompanion(
              title: Value(task.title),
              note: Value(task.note),
              dueDate: Value(task.dueDate),
              reminderDate: Value(task.reminderDate),
              priority: Value(task.priority),
              project: Value(task.project),
              completed: Value(task.completed),
              orderIndex: Value(task.orderIndex),
              createdAt: Value(task.createdAt),
              updatedAt: Value(DateTime.now()),
              deletedAt: Value(task.deletedAt),
            ),
          );

      try {
        if (task.dueDate != null) {
          await ref.read(notificationServiceProvider).scheduleDueNotification(task);
        } else {
          await ref.read(notificationServiceProvider).cancelNotification(task);
        }
      } catch (e) {
        debugPrint('Error updating notification: $e');
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final db = await _db;
      final task = await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
      await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
      
      try {
        final taskModel = task_model.Task(
          id: task.id,
          title: task.title,
          note: task.note,
          dueDate: task.dueDate,
          reminderDate: task.reminderDate,
          priority: task.priority,
          project: task.project,
          completed: task.completed,
          orderIndex: task.orderIndex,
          createdAt: task.createdAt,
          updatedAt: task.updatedAt,
          deletedAt: task.deletedAt,
        );
        await ref.read(notificationServiceProvider).cancelNotification(taskModel);
      } catch (e) {
        debugPrint('Error canceling notification: $e');
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }
}