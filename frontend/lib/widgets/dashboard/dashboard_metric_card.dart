// lib/widgets/dashboard/dashboard_metric_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color color;
  final String? subtitle;

  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headingLarge(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall(color: color.withOpacity(0.8))
                .copyWith(fontWeight: FontWeight.w600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall(color: color.withOpacity(0.5)),
            ),
          ],
        ],
      ),
    );
  }
}
