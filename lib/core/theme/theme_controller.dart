import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _themeKey = 'is_dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _themeMode = preferences.getBool(_themeKey) == true
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, enabled);
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({super.key, required super.notifier, required super.child});

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope tidak ditemukan di widget tree.');
    return scope!.notifier!;
  }
}
