import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/config/locale_selector_screen.dart';
import 'package:todo_app/features/shell/presentation/root_shell.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/features/tasks/presentation/task_form_screen.dart';
import 'package:todo_app/features/tasks/presentation/task_list_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RootShell(),
    ),
    // Keep legacy list route available if needed
    GoRoute(
      path: '/list',
      builder: (context, state) => const TaskListScreen(),
    ),
    GoRoute(
      path: '/task/new',
      builder: (context, state) => const TaskFormScreen(),
    ),
    GoRoute(
      path: '/task/edit',
      builder: (context, state) {
        if (state.extra is Task) {
          final task = state.extra as Task;
          return TaskFormScreen(task: task);
        }
        return const RootShell();
      },
    ),
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => const LocaleSelectorScreen(),
    ),
  ],
);