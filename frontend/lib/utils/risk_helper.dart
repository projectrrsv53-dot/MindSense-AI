import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Color getRiskColor(String riskLevel) {
  switch (riskLevel.trim().toUpperCase()) {
    case "CRITICAL":
      return DoctorColors.highRisk; // Red

    case "HIGH":
      return Colors.deepOrange;

    case "MEDIUM":
      return Colors.amber;

    case "LOW":
      return DoctorColors.lowRisk;

    default:
      return Colors.grey;
  }
}

Color getRiskBackground(String riskLevel) {
  switch (riskLevel.trim().toUpperCase()) {
    case "CRITICAL":
      return Colors.red.shade50;

    case "HIGH":
      return Colors.orange.shade50;

    case "MEDIUM":
      return Colors.amber.shade50;

    case "LOW":
      return Colors.green.shade50;

    default:
      return Colors.grey.shade100;
  }
}