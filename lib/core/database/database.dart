import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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
  AppDatabase._() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._();
  
  factory AppDatabase() => _instance;

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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todo_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}