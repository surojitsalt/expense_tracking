import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expense_tracker_app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Define our vibrant base colors
    const primaryColor = Color(0xFF66BB6A); // Light Green
    const secondaryColor = Color(0xFF42A5F5); // Light Blue
    const surfaceColor = Color(0xFFFFF8E1); // Cream
    const backgroundColor = Color(0xFFFFFDE7); // Off-White
    const errorColor = Color(0xFFEF5350); // Soft Red
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      extensions: const [
        ExpenseTrackerAppColors(
          income: Color(0xFF66BB6A),
          expense: Color(0xFF42A5F5),
          savings: Color(0xFFFFA726),
          incomeLight: Color(0xFFE8F5E9),
          expenseLight: Color(0xFFE3F2FD),
          savingsLight: Color(0xFFFFF3E0),
        ),
      ],
    );
  }
}
