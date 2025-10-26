import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/config/app_config.dart';
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/core/router/router.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/core/theme/theme_controller.dart';
import 'package:todo_app/core/config/locale_controller.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_app/features/tasks/data/notification_service.dart';
import 'package:todo_app/features/timer/presentation/timer_notification_service.dart';
import 'package:todo_app/core/database/database.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Optimize rendering for better performance
    // Note: Configuration is only available after first frame
    // WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;

    final container = ProviderContainer();
  
    // Initialize database in background with optimization
    unawaited(AppDatabase.getInstance());
    
    // Parallelize service initialization for faster startup
    await Future.wait([
      container.read(notificationServiceProvider).initialize(),
      container.read(timerNotificationServiceProvider).initialize(),
      container.read(localeControllerProvider.notifier).loadSavedLocale(),
    ]);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    rethrow;
  }
}class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  Timer? _keepAliveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startKeepAlive();
  }

  @override
  void dispose() {
    _keepAliveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startKeepAlive() {
    // Keep the app alive by periodically checking the database connection
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      AppDatabase.getInstance();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Save any necessary state or perform cleanup
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize any necessary resources
      AppDatabase.getInstance();
    }
  }

  late final config = ref.read(appConfigProvider);

  @override
  Widget build(BuildContext context) {
    try {
      final locale = ref.watch(localeControllerProvider);
      final language = ref.watch(languageControllerProvider);

      return MaterialApp.router(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeControllerProvider) ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 200), // Faster theme transition
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: appRouter,
      builder: (context, child) {
        // Optimize scroll performance
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            physics: const BouncingScrollPhysics(), // Smoother scrolling
          ),
          child: child!,
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      locale: Locale(language), // Use language controller instead of locale controller
    );
    } catch (e) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
