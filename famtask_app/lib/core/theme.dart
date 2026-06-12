import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FamTheme {
  // Brand Colors
  static const Color primary = Color(0xFF8C52FF);      // Vibrant purple
  static const Color secondary = Color(0xFFFF7AE3);    // Vibrant pink
  static const Color darkPurple = Color(0xFF2C1A4D);   // Deep text purple
  static const Color lavender = Color(0xFFEBE3FC);     // Light lavender
  static const Color softBackground = Color(0xFFF5F0FF); // Off-white lavender
  static const Color lightGray = Color(0xFFF0EFF5);

  // Gradient definitions
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFFDCC8FF), Color(0xFFF5EEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient taskCardGradient = LinearGradient(
    colors: [Color(0xFFFFEBF6), Color(0xFFFFF0F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shoppingCardGradient = LinearGradient(
    colors: [Color(0xFFEBF6FF), Color(0xFFF0F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: softBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkPurple,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkPurple,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkPurple,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: darkPurple.withOpacity(0.9),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: darkPurple.withOpacity(0.75),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: darkPurple.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: darkPurple.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: darkPurple.withOpacity(0.35),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
