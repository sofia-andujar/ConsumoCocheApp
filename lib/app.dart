import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'screens/add_refuel_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
class GasApp extends ConsumerWidget {
  const GasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final themeMode = switch (settings.brightnessMode) {
      BrightnessMode.light => ThemeMode.light,
      BrightnessMode.dark => ThemeMode.dark,
      BrightnessMode.system => ThemeMode.system,
    };

    return MaterialApp(
      title: 'CONSUMO MAZDA 2 SOFIA',
      theme: AppTheme.lightTheme(settings.accentColor),
      darkTheme: AppTheme.darkTheme(settings.accentColor),
      themeMode: themeMode,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
        AddRefuelScreen.routeName: (context) => const AddRefuelScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
      },
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          isDark
              ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
              : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        );
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child!,
        );
      },
    );
  }
}
