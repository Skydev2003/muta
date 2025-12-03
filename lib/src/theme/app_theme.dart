import 'package:flutter/material.dart';

class AppTheme {
  // ---------------------------------------------------------
  // COLOR SYSTEM
  // ---------------------------------------------------------
  static const Color bgDark = Color(
    0xFF1A1123,
  ); // พื้นหลังเข้ม
  static const Color cardDark = Color(
    0xFF251832,
  ); // การ์ดเข้ม
  static const Color primaryPurple = Color(0xFF9B32F0);
  static const Color purpleSoft = Color(0xFF6A1BB6);
  static const Color textLight = Colors.white;
  static const Color textSoft = Colors.white70;

  // ---------------------------------------------------------
  // THEME
  // ---------------------------------------------------------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: bgDark,

    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: purpleSoft,
      surface: cardDark,
    ),

    // -------------------- APP BAR --------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textLight),
    ),

    // -------------------- BUTTONS ---------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: textSoft),
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
      ),
    ),

    // -------------------- TEXT ------------------------
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textLight),
      bodyLarge: TextStyle(color: textLight, fontSize: 16),
      titleLarge: TextStyle(
        color: textLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // -------------------- INPUT FIELD -----------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      labelStyle: const TextStyle(color: textSoft),
      hintStyle: const TextStyle(color: textSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  );
}
