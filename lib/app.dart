import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_refuel_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

class TankUpApp extends ConsumerWidget {
  const TankUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = switch (settings.brightnessMode) {
      BrightnessMode.light => ThemeMode.light,
      BrightnessMode.dark => ThemeMode.dark,
      BrightnessMode.system => ThemeMode.system,
    };

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme(settings.accentColor),
      darkTheme: AppTheme.darkTheme(settings.accentColor),
      themeMode: themeMode,
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case HomeScreen.routeName:
            return _buildPageRoute(const HomeScreen());
          case HistoryScreen.routeName:
            return _buildPageRoute(const HistoryScreen());
          case AddRefuelScreen.routeName:
            return _buildPageRoute(const AddRefuelScreen());
          case SettingsScreen.routeName:
            return _buildPageRoute(const SettingsScreen());
          default:
            return _buildPageRoute(const HomeScreen());
        }
      },
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final slideAnimation = animation.drive(tween);

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.6, curve: curve)),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
