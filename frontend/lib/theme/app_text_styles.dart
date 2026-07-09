// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Display / Hero text ──────────────────
  static TextStyle displayLarge({Color? color}) => GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: color ?? PatientColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.nunito(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: color ?? PatientColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // ── Heading ──────────────────────────────
  static TextStyle headingLarge({Color? color}) => GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: color ?? PatientColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headingMedium({Color? color}) => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color ?? PatientColors.textPrimary,
    height: 1.35,
  );

  static TextStyle headingSmall({Color? color}) => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? PatientColors.textPrimary,
    height: 1.4,
  );

  // ── Body ─────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color ?? PatientColors.textSecondary,
    height: 1.6,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: color ?? PatientColors.textSecondary,
    height: 1.6,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? PatientColors.textHint,
    height: 1.5,
  );

  // ── Label / Button ────────────────────────
  static TextStyle labelLarge({Color? color}) => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.white,
    letterSpacing: 0.3,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.white,
    letterSpacing: 0.2,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: color ?? PatientColors.textHint,
    letterSpacing: 0.8,
  );

  // ── Special ─────────────────────────────
  static TextStyle tagline({Color? color}) => GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.white.withOpacity(0.85),
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle appName({Color? color}) => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: color ?? AppColors.white,
    letterSpacing: 1.5,
  );

  static TextStyle metric({Color? color}) => GoogleFonts.nunito(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: color ?? PatientColors.primary,
    height: 1.0,
  );
}
