import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppColors {
  static const c0 = Color(0xFF0D0D1A);
  static const c1 = Color(0xFF12122A);
  static const c2 = Color(0xFF181838);
  static const c3 = Color(0xFF1E1E48);

  static const gold = Color(0xFFF4C430);
  static const gold2 = Color(0xFFFAC775);

  static const hp = Color(0xFFE24B4A);
  static const xp = Color(0xFF5DCAA5);
  static const mp = Color(0xFF85B7EB);

  static const accent = Color(0xFF7F77DD);
  static const accent2 = Color(0xFFAFA9EC);

  static const green = Color(0xFF97C459);
  static const red = Color(0xFFE24B4A);

  static const t1 = Color(0xFFE8E8F8);
  static const t2 = Color(0xFF9999BB);
  static const t3 = Color(0xFF5555AA);

  static const border = Color(0x2E7F77DD);
  static const border2 = Color(0x597F77DD);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.c0,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.gold,
          surface: AppColors.c1,
        ),
        fontFamily: GoogleFonts.dmSans().fontFamily,
        textTheme: const TextTheme(
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
          iconTheme: const IconThemeData(color: AppColors.t2),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xF50D0D1A),
          selectedItemColor: AppColors.accent2,
          unselectedItemColor: AppColors.t3,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
          unselectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        ),
      );
}
