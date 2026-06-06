import 'package:flutter/material.dart';
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
    final accentColor = ref.watch(accentColorProvider);

    return MaterialApp(
      title: 'CONSUMO MAZDA 2 SOFIA',
      theme: AppTheme.lightTheme(accentColor),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
        AddRefuelScreen.routeName: (context) => const AddRefuelScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
      },
    );
  }
}
