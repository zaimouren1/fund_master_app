import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

mixin AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  void logInfo(String message, [dynamic data]) {
    _logger.i(message, error: data);
  }

  void logDebug(String message, [dynamic data]) {
    if (kDebugMode) {
      _logger.d(message, error: data);
    }
  }

  void logWarning(String message, [dynamic data]) {
    _logger.w(message, error: data);
  }

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

void setupLogging() {
  Logger.level = kDebugMode ? Level.debug : Level.error;
}
