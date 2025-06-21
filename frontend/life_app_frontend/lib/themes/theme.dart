import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For web-friendly typography

ThemeData getAppTheme({bool isDark = false}) {
  // Define a color scheme with Material 3 for a harmonious palette
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF9CAF88), // Primary muted green
    primary: const Color(0xFF9CAF88),
    secondary: const Color(0xFFCC7B38), // Complementary amber for accents
    surface: isDark ? Colors.grey[900]! : Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: isDark ? Colors.white : Colors.black87,
    brightness: isDark ? Brightness.dark : Brightness.light,
  );

  return ThemeData(
    // Enable Material 3 for modern design
    useMaterial3: true,
    colorScheme: colorScheme,

    // Scaffold and card backgrounds
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardTheme(
      color: colorScheme.surface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2), // Replaced withOpacity
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8), // Spacious for web
    ),

    // Comprehensive typography with Google Fonts for web readability
    textTheme: GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // For buttons
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0, // Flat design for web
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) { // Replaced MaterialStateProperty
          if (states.contains(WidgetState.disabled)) return Colors.grey[400]; // Replaced MaterialState
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary), // Replaced MaterialStateProperty
        overlayColor: WidgetStateProperty.all(colorScheme.secondary.withValues(alpha: 0.1)), // Replaced withOpacity
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)), // Replaced MaterialStateProperty
        shape: WidgetStateProperty.all( // Replaced MaterialStateProperty
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStateProperty.all( // Replaced MaterialStateProperty
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        elevation: WidgetStateProperty.resolveWith((states) { // Replaced MaterialStateProperty
          return states.contains(WidgetState.hovered) ? 8 : 4; // Replaced MaterialState
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary), // Replaced MaterialStateProperty
        overlayColor: WidgetStateProperty.all(colorScheme.primary.withValues(alpha: 0.1)), // Replaced withOpacity
        textStyle: WidgetStateProperty.all( // Replaced MaterialStateProperty
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    ),

    // Input fields for forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface.withValues(alpha: 0.5), // Replaced withOpacity
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)), // Replaced withOpacity
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)), // Replaced withOpacity
      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)), // Replaced withOpacity
    ),

    // Hover and focus for web interactivity
    hoverColor: colorScheme.primary.withValues(alpha: 0.1), // Replaced withOpacity
    focusColor: colorScheme.secondary.withValues(alpha: 0.3), // Replaced withOpacity

    // Navigation bar for web apps
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.2), // Replaced withOpacity
      labelTextStyle: WidgetStateProperty.all( // Replaced MaterialStateProperty
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // Dialog theme for pop-ups
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}