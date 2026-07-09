// lib/widgets/dashboard/dashboard_section_title.dart
import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final Color? actionColor;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.onActionPressed,
    this.actionLabel,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingSmall()),
        if (onActionPressed != null && actionLabel != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(
              actionLabel!,
              style: AppTextStyles.bodySmall(color: actionColor),
            ),
          ),
      ],
    );
  }
}
