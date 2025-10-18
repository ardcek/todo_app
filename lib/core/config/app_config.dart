import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Environment {
  development,
  production,
}

class AppConfig {
  AppConfig({
    required this.environment,
    required this.shouldCollectCrashlytics,
    required this.shouldCollectAnalytics,
  });

  final Environment environment;
  final bool shouldCollectCrashlytics;
  final bool shouldCollectAnalytics;

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  // TODO: Load from environment variables or build configuration
  return AppConfig(
    environment: Environment.development,
    shouldCollectCrashlytics: false,
    shouldCollectAnalytics: false,
  );
});