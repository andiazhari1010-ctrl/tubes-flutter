import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── Color tokens ──────────────────────────────────────────────────────────
/// Satu palet terkunci: netral gelap + SATU aksen (violet) + emas sebagai
/// sorotan. Warna semantik (hp/xp/mp/momentum/warning) konsisten lintas tema.
class AppColors {
  static bool isDarkMode = true;

  // Permukaan (surface) berjenjang dari paling gelap → paling terang.
  static Color get c0 => isDarkMode ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FA);
  static Color get c1 => isDarkMode ? const Color(0xFF12122A) : const Color(0xFFFFFFFF);
  static Color get c2 => isDarkMode ? const Color(0xFF181838) : const Color(0xFFE8E8F5);
  static Color get c3 => isDarkMode ? const Color(0xFF1E1E48) : const Color(0xFFDDDDF0);

  // Sorotan emas (hadiah, mata uang, mahkota).
  static Color get gold => const Color(0xFFF4C430);
  static Color get gold2 => isDarkMode ? const Color(0xFFFAC775) : const Color(0xFFD49E35);

  // Stat hero — warna semantik tetap, tidak ikut tema.
  static Color get hp => const Color(0xFFE24B4A);
  static Color get xp => const Color(0xFF5DCAA5);
  static Color get mp => const Color(0xFF85B7EB);
  static Color get momentum => const Color(0xFF36D6E7); // dulu literal 0xFF00E5FF

  // Aksen tunggal aplikasi (violet).
  static Color get accent => const Color(0xFF7F77DD);
  static Color get accent2 => isDarkMode ? const Color(0xFFAFA9EC) : const Color(0xFF5A52C0);

  // Status.
  static Color get green => const Color(0xFF97C459);
  static Color get red => const Color(0xFFE24B4A);
  static Color get warning => const Color(0xFFE8943A); // dulu literal 0xFFFF9800/7A45

  // Warna kelas hero (avatar, aksen kartu).
  static Color get classWarrior => accent;
  static Color get classMage => const Color(0xFF3D7FC4);
  static Color get classHealer => const Color(0xFF2E9E7C);
  static Color get classRogue => const Color(0xFFB07A2E);

  // Teks berjenjang.
  static Color get t1 => isDarkMode ? const Color(0xFFE8E8F8) : const Color(0xFF1A1A2E);
  static Color get t2 => isDarkMode ? const Color(0xFF9999BB) : const Color(0xFF555577);
  static Color get t3 => isDarkMode ? const Color(0xFF6E6EA8) : const Color(0xFF8888BB);

  // Garis hairline.
  static Color get border => isDarkMode ? const Color(0x2E7F77DD) : const Color(0x1F7F77DD);
  static Color get border2 => isDarkMode ? const Color(0x597F77DD) : const Color(0x3B7F77DD);
}

/// ─── Radius scale (Shape Consistency Lock) ─────────────────────────────────
/// Aturan: chip/kontrol kecil = sm · item daftar/tombol/input = md ·
/// kartu/panel/sheet = lg · bar/titik/pill = pill. Tidak ada angka radius lain.
class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop =
      BorderRadius.vertical(top: Radius.circular(lg));
}

/// ─── Spacing scale (ritme spasi) ───────────────────────────────────────────
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// ─── Typography ────────────────────────────────────────────────────────────
/// Cinzel untuk display (judul bergaya RPG), DM Sans untuk body. Memanggil
/// GoogleFonts memastikan font benar-benar termuat (bukan fallback diam-diam).
class AppText {
  /// Judul bergaya — layar, kartu, dan label section.
  static TextStyle display(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w700,
    double spacing = 0.5,
  }) =>
      GoogleFonts.cinzel(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing,
      );

  /// Teks isi standar.
  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.4,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
      );
}

class AppTheme {
  static ThemeData get theme => getTheme(AppColors.isDarkMode);

  static ThemeData getTheme(bool isDarkMode) {
    final base = GoogleFonts.dmSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.c0,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: const Color(0xFF2A1A00),
        error: AppColors.red,
        onError: Colors.white,
        surface: AppColors.c1,
        onSurface: AppColors.t1,
      ),
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: base.copyWith(
        bodyLarge: AppText.body(15, color: AppColors.t1),
        bodyMedium: AppText.body(13, color: AppColors.t1),
        bodySmall: AppText.body(11, color: AppColors.t2),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.c0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.display(18, color: AppColors.t1),
        iconTheme: IconThemeData(color: AppColors.t2),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.c0,
        selectedItemColor: AppColors.accent2,
        unselectedItemColor: AppColors.t3,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppText.body(10, weight: FontWeight.w600),
        unselectedLabelStyle: AppText.body(10, weight: FontWeight.w600),
      ),

      // Default global tombol — layar yang men-styleFrom sendiri tetap menimpa,
      // tapi yang tidak kini langsung konsisten.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md + 2, horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppText.body(14, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.t1,
          side: BorderSide(color: AppColors.border2, width: 0.5),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md + 2, horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppText.body(14, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent2,
          textStyle: AppText.body(13, weight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.c1,
        hintStyle: AppText.body(13, color: AppColors.t3),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.accent, width: 1),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.c2,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0.5,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.c3,
        contentTextStyle: AppText.body(13, color: AppColors.t1),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.t3),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.accent.withValues(alpha: 0.3)
                : AppColors.c1),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
