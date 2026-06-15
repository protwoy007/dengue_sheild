import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppColors {
  static const navy      = Color(0xFF0A1628);
  static const teal      = Color(0xFF00695C);
  static const tealLight = Color(0xFFE0F2F1);
  static const tealMid   = Color(0xFFB2DFDB);
  static const gold      = Color(0xFFF57F17);
  static const goldLight = Color(0xFFFFF8E1);
  static const danger    = Color(0xFFC62828);
  static const dangerLight = Color(0xFFFFEBEE);
  static const warning   = Color(0xFFF9A825);
  static const warningLight = Color(0xFFFFF9C4);
  static const success   = Color(0xFF2E7D32);
  static const successLight = Color(0xFFE8F5E9);
  static const slate     = Color(0xFF455A64);
  static const lightGray = Color(0xFFF5F7FA);
  static const cardBg    = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightGray,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.navy,
      secondary: AppColors.teal,
      surface: AppColors.cardBg,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFECEFF1), width: 0.8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navy,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: Color(0xFF78909C),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}
