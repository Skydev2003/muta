import 'package:flutter/material.dart';

class AppTheme {
  // โทนสีของร้านหมูกระทะ
  static const Color bgDark = Color(
    0xFF1E120E,
  ); // พื้นหลังเข้ม
  static const Color cardDark = Color(
    0xFF2B1A15,
  ); // การ์ดเมนู
  static const Color orange = Color.fromARGB(255, 170, 0, 255); // ปุ่มเด่น
  static const Color orangeSoft = Color.fromARGB(255, 86, 0, 125); // เน้นแบบนุ่ม
  static const Color textLight = Colors.white;
  static const Color textSoft = Colors.white70;

  // ---------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: bgDark,

    colorScheme: const ColorScheme.dark(
      primary: orange,
      secondary: orangeSoft,
      surface: cardDark,
    ),

    // -------- APP BAR --------
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textLight),
    ),

    // -------- BUTTON --------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
      ),
    ),

    // -------- TEXT --------
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textLight),
      bodyLarge: TextStyle(color: textLight),
      titleLarge: TextStyle(
        color: textLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // -------- INPUT FIELD --------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      labelStyle: const TextStyle(color: textSoft),
      hintStyle: const TextStyle(color: textSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
