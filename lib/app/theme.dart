import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Қосымшаның заманауи тақырыбы
class AppTheme {
  // ─── Dark theme constants ──────────────────────────────────────
  static const Color darkBg      = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B27);
  static const Color darkCard    = Color(0xFF1E2335);
  // Негізгі түс палитрасы
  static const Color primary = Color(0xFF1A237E);      // Терең көк
  static const Color primaryLight = Color(0xFF3949AB); // Орташа көк
  static const Color accent = Color(0xFF00BCD4);       // Циан акцент
  static const Color gold = Color(0xFFFFB300);         // Алтын
  static const Color surface = Color(0xFFF8F9FF);      // Жарық фон

  // Градиент — AppBar, Login, Profile header үшін
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF3949AB), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: accent,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: const Color(0xFFF0F2FF),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: primary.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        prefixIconColor: primaryLight,
        labelStyle: TextStyle(color: primary.withValues(alpha: 0.7)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      // Filled button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          elevation: 3,
          shadowColor: primary.withValues(alpha: 0.4),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryLight),
      ),

      // Bottom NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 26);
          }
          return IconThemeData(
              color: primary.withValues(alpha: 0.45), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: primary, fontWeight: FontWeight.w700, fontSize: 11);
          }
          return TextStyle(
              color: primary.withValues(alpha: 0.5), fontSize: 10);
        }),
        elevation: 12,
        shadowColor: primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: primary.withValues(alpha: 0.08),
        labelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: primary.withValues(alpha: 0.08),
        thickness: 1,
      ),

      // Text
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: primary, fontWeight: FontWeight.w800, fontSize: 28),
        headlineMedium: TextStyle(
            color: primary, fontWeight: FontWeight.w700, fontSize: 24),
        headlineSmall: TextStyle(
            color: primary, fontWeight: FontWeight.w700, fontSize: 20),
        titleLarge: TextStyle(
            color: primary, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(
            color: primary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: Color(0xFF1A1A2E), fontSize: 15),
        bodyMedium: TextStyle(color: Color(0xFF3A3A5C), fontSize: 14),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: accent,
      surface: darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: darkBg,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: darkCard,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        prefixIconColor: accent,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          elevation: 3,
          shadowColor: primaryLight.withValues(alpha: 0.4),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: accent.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 26);
          }
          return IconThemeData(
              color: Colors.white.withValues(alpha: 0.4), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: accent, fontWeight: FontWeight.w700, fontSize: 11);
          }
          return TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 10);
        }),
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: primaryLight.withValues(alpha: 0.25),
        labelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
        headlineMedium: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24),
        headlineSmall: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        titleLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: Color(0xFFE0E4F8), fontSize: 15),
        bodyMedium: TextStyle(color: Color(0xFFB0B8D4), fontSize: 14),
      ),
    );
  }
}
