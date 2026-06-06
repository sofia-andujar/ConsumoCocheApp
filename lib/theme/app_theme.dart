import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Pastel colors
  static const Color pastelPurple = Color.fromARGB(255, 200, 150, 220); // Primary accent
  static const Color pastelPurpleDark = Color.fromARGB(255, 170, 120, 190);
  static const Color pastelPink = Color.fromARGB(255, 242, 184, 206); // More readable soft pink
  static const Color pastelBlue = Color.fromARGB(255, 148, 186, 238); // Deeper pastel blue
  static const Color pastelGreen = Color.fromARGB(255, 142, 210, 185); // Moderate pastel green
  static const Color pastelOrange = Color.fromARGB(255, 255, 174, 128); // Warmer pastel orange
  static const Color pastelTeal = Color.fromARGB(255, 112, 197, 213); // Pastel teal
  static const Color pastelCream = Color.fromARGB(255, 255, 253, 240); // Very light cream
  static const Color pastelGray = Color.fromARGB(255, 230, 230, 235); // Soft lavender-gray

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
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.black,
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
          elevation: 2,
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
        backgroundColor: accentContainer,
        contentTextStyle: TextStyle(color: accentContainerOnColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}
