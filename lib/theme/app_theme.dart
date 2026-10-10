import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// App colours. Surface/text/accent colours are getters that follow [dark], so
/// the same code renders correctly in light and dark mode.
/// [navy] stays constant: it is the brand colour used for app bars / splash.
class AppColors {
  /// Set by the root widget (see main.dart) whenever the effective theme changes.
  static bool dark = false;

  static const navy = Color(0xFF0A1628);

  static Color _c(Color light, Color darkC) => dark ? darkC : light;

  static Color get ink          => _c(const Color(0xFF0A1628), const Color(0xFFECEFF1)); // primary text
  static Color get slate        => _c(const Color(0xFF455A64), const Color(0xFFA9B7C0)); // secondary text
  static Color get lightGray    => _c(const Color(0xFFF5F7FA), const Color(0xFF0E161D)); // screen background
  static Color get cardBg       => _c(const Color(0xFFFFFFFF), const Color(0xFF17222B)); // cards
  static Color get border       => _c(const Color(0xFFECEFF1), const Color(0xFF263642));
  static Color get chipSelected => _c(const Color(0xFF0A1628), const Color(0xFF26A69A));

  static Color get teal         => _c(const Color(0xFF00695C), const Color(0xFF26A69A));
  static Color get tealLight    => _c(const Color(0xFFE0F2F1), const Color(0xFF143B38));
  static Color get tealMid      => _c(const Color(0xFFB2DFDB), const Color(0xFF2E6B65));
  static Color get gold         => _c(const Color(0xFFF57F17), const Color(0xFFFFB74D));
  static Color get goldLight    => _c(const Color(0xFFFFF8E1), const Color(0xFF3A3018));
  static Color get danger       => _c(const Color(0xFFC62828), const Color(0xFFEF5350));
  static Color get dangerLight  => _c(const Color(0xFFFFEBEE), const Color(0xFF3D2125));
  static Color get warning      => _c(const Color(0xFFF9A825), const Color(0xFFFBC02D));
  static Color get warningLight => _c(const Color(0xFFFFF9C4), const Color(0xFF3A3416));
  static Color get success      => _c(const Color(0xFF2E7D32), const Color(0xFF66BB6A));
  static Color get successLight => _c(const Color(0xFFE8F5E9), const Color(0xFF1D3322));
}

class AppTheme {
  /// Builds the theme for the requested brightness (the colours are read while
  /// [AppColors.dark] is temporarily set, so both themes can be built at once).
  static ThemeData build(bool dark) {
    final prev = AppColors.dark;
    AppColors.dark = dark;
    try {
      return _make(dark);
    } finally {
      AppColors.dark = prev;
    }
  }

  static ThemeData _make(bool dark) {
    final base = dark ? ThemeData.dark() : ThemeData.light();
    final brightness = dark ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.lightGray,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: brightness,
        primary: dark ? AppColors.teal : AppColors.navy,
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
          side: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navy,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: const Color(0xFF78909C),
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
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    );
  }

  /// Kept for backwards compatibility.
  static ThemeData get theme => build(false);
}
