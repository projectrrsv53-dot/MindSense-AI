// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

// ─────────────────────────────────────────
//  PATIENT PALETTE  (lavender + teal)
// ─────────────────────────────────────────
class PatientColors {
  static const Color primary = Color(0xFF7C6FCD);      // deep lavender
  static const Color primaryLight = Color(0xFFB8AEE8);
  static const Color primarySurface = Color(0xFFF0EEFF);
  static const Color accent = Color(0xFF4ECDC4);       // teal
  static const Color accentLight = Color(0xFFB2F0EB);
  static const Color accentSurface = Color(0xFFE8FFFE);
  static const Color gradientStart = Color(0xFF8B7FD4);
  static const Color gradientEnd = Color(0xFF4ECDC4);
  static const Color background = Color(0xFFF7F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFAF9FF);
  static const Color textPrimary = Color(0xFF1A1635);
  static const Color textSecondary = Color(0xFF6B6484);
  static const Color textHint = Color(0xFFB0ABC8);
  static const Color success = Color(0xFF43C59E);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B8A);
  static const Color divider = Color(0xFFEDE9FF);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFF0EEFF), Color(0xFFE8FFFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF6B5FB5), Color(0xFF4ECDC4), Color(0xFF45B7D1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─────────────────────────────────────────
//  DOCTOR PALETTE  (deep blue + white)
// ─────────────────────────────────────────
class DoctorColors {
  static const Color primary = Color(0xFF1A56DB);      // clinical blue
  static const Color primaryLight = Color(0xFF7AACFF);
  static const Color primarySurface = Color(0xFFEBF2FF);
  static const Color accent = Color(0xFF0EA5E9);       // sky blue
  static const Color accentLight = Color(0xFFBAE6FD);
  static const Color gradientStart = Color(0xFF1A56DB);
  static const Color gradientEnd = Color(0xFF0EA5E9);
  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF8FAFF);
  static const Color textPrimary = Color(0xFF0D1B3E);
  static const Color textSecondary = Color(0xFF4A5980);
  static const Color textHint = Color(0xFF9BAED0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color highRisk = Color(0xFFFF4757);
  static const Color lowRisk = Color(0xFF2ED573);
  static const Color divider = Color(0xFFDFEAFF);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFEBF2FF), Color(0xFFBAE6FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D1B3E), Color(0xFF1A56DB), Color(0xFF0EA5E9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─────────────────────────────────────────
//  ADMIN PALETTE  (slate grey + white)
// ─────────────────────────────────────────
class AdminColors {
  static const Color primary = Color(0xFF334155);      // slate
  static const Color primaryLight = Color(0xFF64748B);
  static const Color primarySurface = Color(0xFFF1F5F9);
  static const Color accent = Color(0xFF6366F1);       // indigo accent
  static const Color gradientStart = Color(0xFF1E293B);
  static const Color gradientEnd = Color(0xFF334155);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color pending = Color(0xFFF59E0B);
  static const Color approved = Color(0xFF22C55E);
  static const Color rejected = Color(0xFFEF4444);
  static const Color divider = Color(0xFFE2E8F0);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────
//  SHARED NEUTRAL COLORS
// ─────────────────────────────────────────
class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color overlay = Color(0x80000000);
  static const Color shimmer1 = Color(0xFFE8E8E8);
  static const Color shimmer2 = Color(0xFFD0D0D0);

  // ── CENTRALIZED RISK HELPER ──────────────────────────────────────────
  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.trim().toUpperCase()) {
      case "CRITICAL":
        return DoctorColors.highRisk; // Red
      case "HIGH":
        return Colors.deepOrange;
      case "MODERATE":
      case "MEDIUM":
        return Colors.amber;
      case "LOW":
        return DoctorColors.lowRisk; // Green
      default:
        return Colors.grey;
    }
  }

  static Color getRiskBackground(String riskLevel) {
    switch (riskLevel.trim().toUpperCase()) {
      case "CRITICAL":
        return Colors.red.shade50;
      case "HIGH":
        return Colors.orange.shade50;
      case "MODERATE":
      case "MEDIUM":
        return Colors.amber.shade50;
      case "LOW":
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }
}