import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يدير تبديل الثيم (فاتح/داكن/تلقائي حسب النظام) ويحفظ اختيار المستخدم محليًا
/// بحيث يُستعاد نفس الاختيار عند إعادة فتح التطبيق.
class ThemeController extends ChangeNotifier {
  static const _prefKey = 'eduspirit_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }
}
