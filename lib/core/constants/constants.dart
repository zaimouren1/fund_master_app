import 'dart:ui';

/// 应用常量定义
class AppInfo {
  static const String appName = 'AlphaFund';
  static const String version = '2.1.0';
  static const String buildNumber = '210';
  static const String packageName = 'com.alphafund.app';
}

/// API 配置
class ApiConfig {
  static const String fundBaseUrl = 'http://fundgz.1234567.com.cn';
  static const String fundApiPath = '/js/';
  static const String eastmoneyBaseUrl = 'http://api.fund.eastmoney.com';
  static const String deepseekBaseUrl = 'https://api.deepseek.com/v1';
  static const String deepseekModel = 'deepseek-chat';
  static const Duration timeout = Duration(seconds: 30);
}

/// 缓存 Key
class CacheKeys {
  static const String hotFunds = 'hot_funds';
  static const String fundHistory = 'fund_history_';
  static const String userToken = 'user_token';
}

/// 导航路由
class Routes {
  static const String home = '/';
  static const String portfolio = '/portfolio';
  static const String estimator = '/estimator';
  static const String market = '/market';
  static const String recommend = '/recommend';
}

/// 基金代码
class FundCodes {
  static const List<String> hotFunds = [
    '161725', '005827', '020274', '110022', '001594', '005196', '006663', '512010',
  ];
}

/// 颜色定义
abstract class AppColors {
  static const Color primary = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color success = Color(0xFF26A69A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color upColor = Color(0xFF26A69A);
  static const Color downColor = Color(0xFFEF5350);
}
