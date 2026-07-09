// lib/widgets/admin/recent_activity_card.dart

import 'package:flutter/material.dart';

import '../../models/recent_activity.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class RecentActivityCard extends StatelessWidget {
  final RecentActivity activity;

  const RecentActivityCard({
    super.key,
    required this.activity,
  });

  IconData get _icon {
    switch (activity.type) {
      case "doctor_verified":
        return Icons.verified_rounded;

      case "critical_session":
        return Icons.warning_amber_rounded;

      case "patient_registered":
        return Icons.person_add_alt_1_rounded;

      case "doctor_rejected":
        return Icons.cancel_rounded;

      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get _color {
    switch (activity.type) {
      case "doctor_verified":
        return Colors.green;

      case "critical_session":
        return Colors.red;

      case "patient_registered":
        return Colors.blue;

      case "doctor_rejected":
        return Colors.orange;

      default:
        return AdminColors.primary;
    }
  }

  String get _title {
    switch (activity.type) {
      case "doctor_verified":
        return "Doctor Verified";

      case "critical_session":
        return "Critical Session";

      case "patient_registered":
        return "Patient Registered";

      case "doctor_rejected":
        return "Doctor Rejected";

      default:
        return "Activity";
    }
  }

  String get _subtitle {
    switch (activity.type) {
      case "doctor_verified":
        return "${activity.title} has been approved.";

      case "critical_session":
        return "${activity.title} requires immediate attention.";

      case "patient_registered":
        return "${activity.title} joined the platform.";

      case "doctor_rejected":
        return "${activity.title} verification rejected.";

      default:
        return activity.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _color.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CircleAvatar(
            radius: 24,
            backgroundColor: _color.withOpacity(0.15),
            child: Icon(
              _icon,
              color: _color,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  _title,
                  style: AppTextStyles.headingSmall(
                    color: AdminColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _subtitle,
                  style: AppTextStyles.bodyMedium(
                    color: AdminColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AdminColors.textHint,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      activity.time,
                      style: AppTextStyles.bodySmall(
                        color: AdminColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}