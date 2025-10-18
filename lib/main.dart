import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/config/app_config.dart';
import 'package:todo_app/core/router/router.dart';
import 'package:todo_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'Todo App',
      debugShowCheckedModeBanner: !config.isProduction,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
