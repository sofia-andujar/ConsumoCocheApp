import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Pastel colors
  static const Color pastelPurple = Color.fromARGB(255, 200, 150, 220);
  static const Color pastelPurpleDark = Color.fromARGB(255, 170, 120, 190);
  static const Color pastelPink = Color.fromARGB(255, 242, 184, 206);
  static const Color pastelBlue = Color.fromARGB(255, 148, 186, 238);
  static const Color pastelGreen = Color.fromARGB(255, 142, 210, 185);
  static const Color pastelOrange = Color.fromARGB(255, 255, 174, 128);
  static const Color pastelTeal = Color.fromARGB(255, 112, 197, 213);
  static const Color pastelCream = Color.fromARGB(255, 250, 248, 242);
  static const Color pastelGray = Color.fromARGB(255, 230, 230, 235);

  // Dark mode fixed colors
  static const Color darkBackground = Color(0xFF121220);
  static const Color darkSurface = Color(0xFF1E1E30);
  static const Color darkCard = Color(0xFF28283E);
  static const Color darkOnSurface = Color(0xFFE8E0F0);

  static const Color defaultAccentColor = pastelPurple;
  static const List<Color> accentColors = [
    pastelPurple,
    pastelBlue,
    pastelGreen,
    pastelOrange,
    pastelTeal,
  ];

  static Color _onColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color _darken(Color color, [double amount = .14]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static Color _lighten(Color color, [double amount = .12]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color _themeBackground(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation * 0.38).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.46).clamp(0.0, 1.0))
        .toColor();
  }

  static ThemeData lightTheme(Color accentColor) {
    final accentContainer = _darken(accentColor, .18);
    final accentBorder = accentColor.withAlpha(128);
    final accentShadowColor = accentColor.withAlpha(51);
    final accentOnColor = _onColor(accentColor);
    final accentContainerOnColor = _onColor(accentContainer);
    final backgroundColor = _themeBackground(accentColor);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
      secondary: pastelPink,
      tertiary: pastelBlue,
    ).copyWith(
      primaryContainer: accentContainer,
      surface: pastelCream,
      outline: const Color.fromARGB(255, 150, 120, 170),
      onPrimary: accentOnColor,
      onSurface: const Color.fromARGB(255, 50, 50, 70),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor,
        foregroundColor: accentOnColor,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: pastelCream,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: accentShadowColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: accentOnColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pastelCream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentContainer, width: 2),
        ),
        labelStyle: TextStyle(color: accentColor),
        prefixIconColor: accentColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: accentOnColor,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: TextStyle(color: accentContainerOnColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: pastelCream,
        selectedColor: accentColor,
        side: BorderSide(color: accentColor),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 50, 50, 70)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: pastelGray,
      ),
    );
  }

  static ThemeData darkTheme(Color accentColor) {
    final accentLight = _lighten(accentColor, 0.08);
    final accentBorder = accentColor.withAlpha(100);
    final accentOnColor = _onColor(accentColor);
    final accentContainerOnColor = _onColor(accentLight);
    const surfaceColor = darkSurface;
    const cardColor = darkCard;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
      secondary: pastelPink,
      tertiary: pastelBlue,
    ).copyWith(
      primaryContainer: darkCard,
      surface: surfaceColor,
      outline: accentColor.withAlpha(100),
      onPrimary: accentOnColor,
      onSurface: darkOnSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: darkBackground,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black.withAlpha(77),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: accentOnColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: TextStyle(color: accentColor),
        prefixIconColor: accentColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: accentOnColor,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: TextStyle(color: accentContainerOnColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: accentColor,
        side: BorderSide(color: accentColor),
        labelStyle: const TextStyle(color: darkOnSurface),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: darkCard,
      ),
    );
  }
}
