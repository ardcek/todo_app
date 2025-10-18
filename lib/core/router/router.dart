import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/features/tasks/models/task.dart';
import 'package:todo_app/features/tasks/presentation/task_form_screen.dart';
import 'package:todo_app/features/tasks/presentation/task_list_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/task/new',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/task/edit',
        builder: (context, state) {
          final task = state.extra as Task;
          return TaskFormScreen(task: task);
        },
      ),
    ],
  );

  ref.onDispose(() {
    _router.dispose();
  });

  return _router;
}