import 'package:flutter/material.dart';

/// نظام الألوان الكامل لتطبيق EduSpirit — مطابق للهوية البصرية في التصميم:
/// أزرق أساسي بدرجاته + أبيض/رمادي فاتح + كحلي داكن + ألوان توكيد (أخضر/برتقالي/أحمر/بنفسجي).
class AppColors {
  AppColors._();

  // ----- Primary Blue Shades -----
  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryDark = Color(0xFF1A4FC4);
  static const Color primaryLight = Color(0xFF6C9CFF);
  static const Color primarySoft = Color(0xFFEAF1FF);

  // ----- Secondary -----
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F7FB);
  static const Color darkNavy = Color(0xFF0B1220);
  static const Color darkNavySurface = Color(0xFF121B2E);
  static const Color darkNavyCard = Color(0xFF19233A);

  // ----- Accents -----
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // ----- Text -----
  static const Color textPrimaryLight = Color(0xFF14213D);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF3F5F9);
  static const Color textSecondaryDark = Color(0xFFA7B0C0);

  /// ألوان المواد الدراسية الافتراضية (Color Coding) — تُستخدم بالتناوب عند إنشاء مادة جديدة.
  static const List<Color> courseColorPalette = [
    primary, accentGreen, accentOrange, accentPurple, accentRed,
    Color(0xFF06B6D4), Color(0xFFEC4899),
  ];
}
