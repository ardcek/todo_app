import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/core/database/database.dart';
import 'package:todo_app/features/tasks/models/task.dart' as task_model;

part 'task_repository.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return TaskRepository(ref.watch(appDatabaseProvider), ref);
}

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

class TaskRepository {
  TaskRepository(this._db, this.ref);

  final AppDatabase _db;
  final TaskRepositoryRef ref;

  Future<List<Task>> getAllTasks() async {
    final tasks = await _db.select(_db.tasks).get();
    return tasks.map((task) {
      return Task(
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
    }).toList();
  }

  Future<task_model.Task> createTask(String title) async {
    final now = DateTime.now();
    final maxOrderIndexQuery = await (_db.select(_db.tasks)
          ..orderBy([(t) => OrderingTerm.desc(t.orderIndex)])
          ..limit(1))
        .map((t) => t.orderIndex)
        .getSingleOrNull();

    final maxOrderIndex = maxOrderIndexQuery ?? 0;

    final taskId = await _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            title: title,
            orderIndex: maxOrderIndex + 1,
            createdAt: now,
            updatedAt: now,
          ),
        );

    final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId)))
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

    // Notification support will be added later
    // if (task.reminderDate != null) {
    //   await scheduleTaskReminder(newTask);
    // }

    return newTask;
  }

  Future<void> updateTask(task_model.Task task) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
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

    // Notification support will be added later
    // await updateTaskReminder(task);
  }

  Future<void> deleteTask(int id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }
}