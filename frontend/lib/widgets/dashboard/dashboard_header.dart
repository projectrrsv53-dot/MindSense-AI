// lib/widgets/dashboard/dashboard_header.dart

import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color textColor;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: AppTextStyles.displayMedium(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium(color: textColor.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
