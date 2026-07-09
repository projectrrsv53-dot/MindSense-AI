// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Patient Theme (Lavender + Teal) ─────────────────────────────
  static ThemeData get patientTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PatientColors.primary,
      primary: PatientColors.primary,
      secondary: PatientColors.accent,
      surface: PatientColors.surface,
      background: PatientColors.background,
      error: PatientColors.error,
    ),
    scaffoldBackgroundColor: PatientColors.background,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: PatientColors.background,
      foregroundColor: PatientColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: PatientColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: PatientColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PatientColors.surface,
      labelStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: PatientColors.textSecondary,
      ),
      hintStyle: GoogleFonts.nunito(
        fontSize: 14,
        color: PatientColors.textHint,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: PatientColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: PatientColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PatientColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PatientColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PatientColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) return AppColors.white.withOpacity(0.08);
          return null;
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PatientColors.primary,
        textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PatientColors.primary,
        side: const BorderSide(color: PatientColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
      ),
    ),
    dividerTheme: const DividerThemeData(color: PatientColors.divider, thickness: 1),
    cardTheme: CardThemeData(
      color: PatientColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PatientColors.divider),
      ),
    ),
  );

  // ── Doctor Theme (Deep Blue + White) ────────────────────────────
  static ThemeData get doctorTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DoctorColors.primary,
      primary: DoctorColors.primary,
      secondary: DoctorColors.accent,
      surface: DoctorColors.surface,
      background: DoctorColors.background,
      error: DoctorColors.error,
    ),
    scaffoldBackgroundColor: DoctorColors.background,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: DoctorColors.background,
      foregroundColor: DoctorColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DoctorColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: DoctorColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DoctorColors.surface,
      labelStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DoctorColors.textSecondary,
      ),
      hintStyle: GoogleFonts.nunito(fontSize: 14, color: DoctorColors.textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DoctorColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DoctorColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DoctorColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DoctorColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) return AppColors.white.withOpacity(0.08);
          return null;
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DoctorColors.primary,
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
      ),
    ),
    dividerTheme: const DividerThemeData(color: DoctorColors.divider, thickness: 1),
    cardTheme: CardThemeData(
      color: DoctorColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DoctorColors.divider),
      ),
    ),
  );

  // ── Admin Theme (Slate Grey + White) ────────────────────────────
  static ThemeData get adminTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AdminColors.primary,
      primary: AdminColors.primary,
      secondary: AdminColors.accent,
      surface: AdminColors.surface,
      background: AdminColors.background,
      error: AdminColors.error,
    ),
    scaffoldBackgroundColor: AdminColors.background,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AdminColors.background,
      foregroundColor: AdminColors.textPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AdminColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AdminColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AdminColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AdminColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) return AppColors.white.withOpacity(0.08);
          return null;
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AdminColors.primary,
      ).copyWith(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AdminColors.divider, thickness: 1),
  );
}