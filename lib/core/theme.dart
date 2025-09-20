import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Helper function to get the appropriate SystemUiOverlayStyle
/// based on the AppBar background color and transparency
SystemUiOverlayStyle getSystemUiOverlayStyle({
  Color? statusBarColor,
  bool isTransparent = false,
  Brightness? statusBarIconBrightness,
}) {
  final effectiveStatusBarColor = isTransparent
      ? Colors.transparent
      : statusBarColor ?? AppColors.surface;

  final effectiveIconBrightness =
      statusBarIconBrightness ??
      (isTransparent || _isLightColor(effectiveStatusBarColor)
          ? Brightness.dark
          : Brightness.light);

  return SystemUiOverlayStyle(
    statusBarColor: effectiveStatusBarColor,
    statusBarIconBrightness: effectiveIconBrightness,
    statusBarBrightness: effectiveIconBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark, // For iOS compatibility
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}

/// Helper function to determine if a color is light or dark
bool _isLightColor(Color color) {
  final luminance = color.computeLuminance();
  return luminance > 0.5;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryBlue,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryGreen,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onBackground: AppColors.text,
    ),
    textTheme: GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      iconTheme: const IconThemeData(color: AppColors.text),
      titleTextStyle: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      systemOverlayStyle: getSystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
  );
}
