import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderDate => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get project => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get color => text().nullable()();
}

class TaskTags extends Table {
  IntColumn get taskId => integer().references(Tasks, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

@DriftDatabase(tables: [Tasks, Tags, TaskTags])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;
  static Future<AppDatabase> _initialization = _initialize();

  static Future<AppDatabase> _initialize() async {
    final executor = await _openConnection();
    _instance = AppDatabase._(executor);
    return _instance!;
  }

  AppDatabase._(QueryExecutor executor) : super(executor);
  
  static Future<AppDatabase> getInstance() async {
    return await _initialization;
  }

  factory AppDatabase() {
    if (_instance == null) {
      throw StateError('Database instance not initialized. Please call getInstance() first.');
    }
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add migration logic here when schema changes
      },
    );
  }
}

Future<QueryExecutor> _openConnection() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todo_app.sqlite'));
    
    // Ensure directory exists
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    // Try to open database with configurations
    try {
      final db = NativeDatabase(
        file,
      );
      // Configure database for better performance and stability
      (db as QueryExecutor).runCustom('PRAGMA journal_mode=WAL');
      (db as QueryExecutor).runCustom('PRAGMA synchronous=NORMAL');
      (db as QueryExecutor).runCustom('PRAGMA busy_timeout=5000');
      return db;
    } catch (e) {
      final db = await NativeDatabase.createInBackground(file);
      return db;
    }
  } catch (e, stack) {
    rethrow;
  }
}