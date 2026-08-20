import 'package:flutter/material.dart';
import 'package:shopease_mobile/services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({required this.storageService});

  final LocalStorageService storageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> restoreTheme() async {
    final savedTheme = await storageService.getThemeMode();
    if (savedTheme == null) return;
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await storageService.saveThemeMode(mode.name);
  }
}