import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool isDarkMode = true;

  static Color get c0 => isDarkMode ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FA);
  static Color get c1 => isDarkMode ? const Color(0xFF12122A) : const Color(0xFFFFFFFF);
  static Color get c2 => isDarkMode ? const Color(0xFF181838) : const Color(0xFFE8E8F5);
  static Color get c3 => isDarkMode ? const Color(0xFF1E1E48) : const Color(0xFFDDDDF0);

  static Color get gold => const Color(0xFFF4C430);
  static Color get gold2 => isDarkMode ? const Color(0xFFFAC775) : const Color(0xFFD49E35);

  static Color get hp => const Color(0xFFE24B4A);
  static Color get xp => const Color(0xFF5DCAA5);
  static Color get mp => const Color(0xFF85B7EB);

  static Color get accent => const Color(0xFF7F77DD);
  static Color get accent2 => isDarkMode ? const Color(0xFFAFA9EC) : const Color(0xFF5A52C0);

  static Color get green => const Color(0xFF97C459);
  static Color get red => const Color(0xFFE24B4A);

  static Color get t1 => isDarkMode ? const Color(0xFFE8E8F8) : const Color(0xFF1A1A2E);
  static Color get t2 => isDarkMode ? const Color(0xFF9999BB) : const Color(0xFF555577);
  static Color get t3 => isDarkMode ? const Color(0xFF5555AA) : const Color(0xFF8888BB);

  static Color get border => isDarkMode ? const Color(0x2E7F77DD) : const Color(0x1F7F77DD);
  static Color get border2 => isDarkMode ? const Color(0x597F77DD) : const Color(0x3B7F77DD);
}

class AppTheme {
  static ThemeData get theme => getTheme(AppColors.isDarkMode);

  static ThemeData getTheme(bool isDarkMode) {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.c0,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: Colors.black,
        error: AppColors.red,
        onError: Colors.white,
        surface: AppColors.c1,
        onSurface: AppColors.t1,
      ),
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: AppColors.t1),
        bodySmall: TextStyle(color: AppColors.t2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.c0,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: GoogleFonts.cinzel().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.t1,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.t2),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.c0,
        selectedItemColor: AppColors.accent2,
        unselectedItemColor: AppColors.t3,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        unselectedLabelStyle:
            const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    );
  }
}
