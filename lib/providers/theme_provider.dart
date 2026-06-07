import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

enum BrightnessMode { light, dark, system }

class ThemeSettings {
  final Color accentColor;
  final BrightnessMode brightnessMode;

  const ThemeSettings({
    this.accentColor = AppTheme.defaultAccentColor,
    this.brightnessMode = BrightnessMode.light,
  });
}

class ThemeSettingsNotifier extends StateNotifier<ThemeSettings> {
  ThemeSettingsNotifier() : super(const ThemeSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final accentIndex = prefs.getInt('accentColorIndex') ?? 0;
    final brightnessStr = prefs.getString('brightnessMode') ?? 'light';
    state = ThemeSettings(
      accentColor: AppTheme.accentColors[accentIndex.clamp(0, AppTheme.accentColors.length - 1)],
      brightnessMode: BrightnessMode.values.firstWhere(
        (m) => m.name == brightnessStr,
        orElse: () => BrightnessMode.light,
      ),
    );
  }

  Future<void> setAccentColor(Color color) async {
    state = ThemeSettings(accentColor: color, brightnessMode: state.brightnessMode);
    final index = AppTheme.accentColors.indexOf(color);
    if (index >= 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('accentColorIndex', index);
    }
  }

  Future<void> setBrightnessMode(BrightnessMode mode) async {
    state = ThemeSettings(accentColor: state.accentColor, brightnessMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('brightnessMode', mode.name);
  }
}

final themeSettingsProvider = StateNotifierProvider<ThemeSettingsNotifier, ThemeSettings>((ref) {
  return ThemeSettingsNotifier();
});
