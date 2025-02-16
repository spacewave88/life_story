import 'package:flutter/material.dart';

ThemeData getAppTheme() {
  return ThemeData(
    // Primary color for app bar, buttons, etc.
    primaryColor: const Color(0xFF9CAF88),
    
    // Background color for scaffolds and cards
    scaffoldBackgroundColor: Colors.white,
    
    // Color for text, icons, etc.
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
      ),
    ),
    
    // App bar theme - will affect the SliverAppBar and MenuBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF9CAF88),
      foregroundColor: Colors.black, // Text and icon color in the app bar
    ),
    
    // Button theme
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(0xFF9CAF88),
      textTheme: ButtonTextTheme.primary,
    ),
    
    // Elevated button theme for consistency
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9CAF88), // Replaced 'primary' with 'backgroundColor'
        foregroundColor: Colors.white, // Replaced 'onPrimary' with 'foregroundColor'
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    
    // Hover color for interactive elements like TextLink
    hoverColor: Colors.black.withOpacity(0.1),

    // Card theme - for any card-like components you might use
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 4,
    ));
}
    // Other theme custom