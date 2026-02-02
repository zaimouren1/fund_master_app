import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

/// 缓存服务
class CacheService {
  static final CacheService _instance = CacheService._();
  factory CacheService() => _instance;
  CacheService._();

  // 缓存过期时间（分钟）
  static const int valuationExpiry = 5;     // 估值数据5分钟
  static const int historyExpiry = 1440;    // 历史数据1天
  static const int marketExpiry = 1;        // 市场数据1分钟

  /// 保存数据到缓存
  Future<void> save(String key, dynamic data, {int expiryMinutes = 60}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiryMinutes * 60 * 1000,
    };
    await prefs.setString('cache_$key', json.encode(cacheData));
  }

  /// 获取缓存数据
  dynamic get(String key) {
    // 这里简化处理，实际应该异步
    return null;
  }

  /// 异步获取缓存
  Future<dynamic> getAsync(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheStr = prefs.getString('cache_$key');
    
    if (cacheStr == null) return null;
    
    try {
      final cacheData = json.decode(cacheStr);
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - timestamp > expiry) {
        // 缓存已过期
        await prefs.remove('cache_$key');
        return null;
      }
      
      return cacheData['data'];
    } catch (e) {
      return null;
    }
  }

  /// 清除缓存
  Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
  }

  /// 清除所有缓存
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// 获取缓存大小
  Future<String> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    int totalSize = 0;
    
    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }
    
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(2)} KB';
    return '${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB';
  }
}

/// 缓存键名常量
class CacheKeys {
  static const String valuation = 'valuation';
  static const String history = 'history';
  static const String market = 'market';
  static const String holdings = 'holdings';
  static const String settings = 'settings';
}
