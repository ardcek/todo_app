// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Todo App';

  @override
  String get tasks => 'Tasks';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskTitle => 'What needs to be done?';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskDueDate => 'Due Date';

  @override
  String get taskPriority => 'Priority';

  @override
  String get taskProject => 'Project';

  @override
  String get notSet => 'Not set';

  @override
  String get reminder => 'Reminder';

  @override
  String clearField(String field) {
    return 'Clear $field';
  }

  @override
  String get projectHelperText =>
      'Projects help you organize related tasks together';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get markIncomplete => 'Mark Incomplete';

  @override
  String get highPriority => 'High';

  @override
  String get mediumPriority => 'Medium';

  @override
  String get lowPriority => 'Low';

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get addYourFirstTask => 'Add your first task';

  @override
  String get search => 'Search tasks';

  @override
  String get filterTasks => 'Filter tasks';

  @override
  String get sortTasks => 'Sort tasks';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get next7Days => 'Next 7 Days';

  @override
  String get all => 'All';

  @override
  String get completed => 'Completed';

  @override
  String get incomplete => 'Incomplete';

  @override
  String get noResults => 'No results found';

  @override
  String get noTasksDescription =>
      'Your task list is empty. Get started by adding your first task.';
}
