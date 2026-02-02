import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AlphaFund 工业级主题系统
class AppTheme {
  // 品牌色
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  
  // 语义色
  static const Color success = Color(0xFF26A69A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);
  
  // 涨跌颜色
  static const Color upColor = Color(0xFF26A69A);
  static const Color downColor = Color(0xFFEF5350);
  
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  /// 浅色主题
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: const Color(0xFFF8FAFC),
      background: const Color(0xFFF1F5F9),
      error: error,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'NotoSansSC',
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: white,
        indicatorColor: primary.withOpacity(0.1),
        labelTextStyle: const MaterialStateProperty.all(TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: const Color(0xFF334155)),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: const Color(0xFF475569)),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: const Color(0xFF64748B)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFCBD5E1)),
      ),
      
      dividerColor: const Color(0xFFE2E8F0),
      dialogTheme: DialogTheme(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
    );
  }
  
  /// 深色主题
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      primary: primaryLight,
      secondary: secondaryLight,
      surface: const Color(0xFF0F172A),
      background: const Color(0xFF020617),
      error: error,
      brightness: Brightness.dark,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'NotoSansSC',
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        indicatorColor: primaryLight.withOpacity(0.2),
        labelTextStyle: const MaterialStateProperty.all(TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: CardTheme(
        color: const Color(0xFF1E293B),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
      ),
      
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: white),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: white),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: white),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: white),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: white),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: white),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFE2E8F0)),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFE2E8F0)),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: const Color(0xFFCBD5E1)),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: const Color(0xFF94A3B8)),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: const Color(0xFF64748B)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
      ),
      
      dividerColor: const Color(0xFF334155),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
    );
  }
}

/// 涨跌颜色扩展
extension PriceColor on double {
  Color get priceColor {
    if (this > 0) return AppTheme.upColor;
    if (this < 0) return AppTheme.downColor;
    return Colors.grey;
  }
}

/// 涨跌幅文本样式
class PriceChangeText extends StatelessWidget {
  final double value;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PriceChangeText({super.key, required this.value, this.fontSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    final color = value.priceColor;
    final prefix = value > 0 ? '+' : '';
    return Text(
      '$prefix${value.toStringAsFixed(2)}%',
      style: TextStyle(
        color: color,
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w600,
      ),
    );
  }
}
