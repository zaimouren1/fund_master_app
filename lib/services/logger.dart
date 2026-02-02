import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志服务
class Logger {
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static LogLevel get level => _currentLevel;

  /// 设置日志级别
  static void setLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// Debug日志
  static void d(String message, {String? tag}) {
    if (_currentLevel.index <= LogLevel.debug.index) {
      _print('DEBUG', tag, message);
    }
  }

  /// Info日志
  static void i(String message, {String? tag}) {
    if (_currentLevel.index <= LogLevel.info.index) {
      _print('INFO', tag, message);
    }
  }

  /// Warning日志
  static void w(String message, {String? tag, dynamic error}) {
    if (_currentLevel.index <= LogLevel.warning.index) {
      _print('WARN', tag, message);
      if (error != null) {
        _print('WARN', tag, 'Error: $error');
      }
    }
  }

  /// Error日志
  static void e(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (_currentLevel.index <= LogLevel.error.index) {
      _print('ERROR', tag, message);
      if (error != null) {
        _print('ERROR', tag, 'Error: $error');
      }
      if (stackTrace != null) {
        _print('ERROR', tag, 'StackTrace: $stackTrace');
      }
    }
  }

  static void _print(String level, String? tag, String message) {
    final timestamp = DateTime.now().toIso8601String().split('T')[1].substring(0, 12);
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('[$timestamp][$level]$tagStr $message');
  }
}

/// 常用标签
class LogTags {
  static const String api = 'API';
  static const String cache = 'CACHE';
  static const String auth = 'AUTH';
  static const String ai = 'AI';
  static const String ui = 'UI';
  static const String data = 'DATA';
}
