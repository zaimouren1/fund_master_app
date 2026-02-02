import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 数字格式扩展
extension NumberFormatExtension on double {
  String toPercent({int decimals = 2}) => '${(this * 100).toStringAsFixed(decimals)}%';
  String toCurrency({String symbol = '¥', int decimals = 2}) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: decimals).format(this);
  }
  String toNumberString({int decimals = 2}) => NumberFormat('#,##0.${'0' * decimals}').format(this);
  String toCompactString() {
    if (this >= 100000000) return '${(this / 100000000).toStringAsFixed(1)}亿';
    if (this >= 10000) return '${(this / 10000).toStringAsFixed(1)}万';
    return toNumberString();
  }
}

/// 日期格式扩展
extension DateTimeExtension on DateTime {
  String toDateString({String format = 'yyyy-MM-dd'}) => DateFormat(format).format(this);
  String toDateTimeString({String format = 'yyyy-MM-dd HH:mm:ss'}) => DateFormat(format).format(this);
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);
    if (difference.inSeconds < 60) return '刚刚';
    if (difference.inMinutes < 60) return '${difference.inMinutes}分钟前';
    if (difference.inHours < 24) return '${difference.inHours}小时前';
    if (difference.inDays < 7) return '${difference.inDays}天前';
    return toDateString();
  }
}

/// 字符串扩展
extension StringExtension on String {
  bool isValidFundCode() => RegExp(r'^\d{6}$').hasMatch(this);
}

/// List 扩展
extension ListExtension<T> on List<T> {
  T? safeGet(int index) => (index < 0 || index >= length) ? null : this[index];
}

/// BuildContext 扩展
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// 数值范围验证
extension RangeValidation on double {
  double clampDouble(double min, double max) => this.clamp(min, max) as double;
  bool inRange(double min, double max) => this >= min && this <= max;
}
