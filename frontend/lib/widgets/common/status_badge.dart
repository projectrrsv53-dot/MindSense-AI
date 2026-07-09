// lib/widgets/common/status_badge.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.bgColor,
  });

  factory StatusBadge.risk(String riskLevel) {
    final Color c = AppColors.getRiskColor(riskLevel);
    return StatusBadge(
      label: riskLevel.toUpperCase(),
      color: c,
      bgColor: c.withOpacity(0.12),
    );
  }

  factory StatusBadge.verificationStatus(String status) {
    Color c;
    switch (status) {
      case 'approved':
        c = AdminColors.approved;
        break;
      case 'rejected':
        c = AdminColors.rejected;
        break;
      default:
        c = AdminColors.pending;
    }
    final label = status[0].toUpperCase() + status.substring(1);
    return StatusBadge(label: label, color: c, bgColor: c.withOpacity(0.12));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
