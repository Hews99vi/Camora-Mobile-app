import 'dart:developer' as developer;

class Logger {
  static void log(String message, {String? name}) {
    developer.log(message, name: name ?? 'App');
  }

  static void error(String message, {Object? error, String? name}) {
    developer.log(
      message,
      name: name ?? 'App',
      error: error,
    );
  }

  static void info(String message, {String? name}) {
    developer.log(message, name: name ?? 'App');
  }

  static void debug(String message, {String? name}) {
    developer.log(message, name: name ?? 'App');
  }

  static void success(String message, {String? name}) {
    developer.log('✓ $message', name: name ?? 'App');
  }

  static void warning(String message, {String? name}) {
    developer.log('⚠ $message', name: name ?? 'App');
  }
}
