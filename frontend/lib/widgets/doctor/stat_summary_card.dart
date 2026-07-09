// lib/widgets/doctor/stat_summary_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class StatSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;

  const StatSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.divider),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? color.withOpacity(0.12) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: gradient != null ? AppColors.white : color, size: 20),
          ),
          const SizedBox(height: 14),

          // Value
          Text(
            value,
            style: AppTextStyles.metric(color: color),
          ),
          const SizedBox(height: 4),

          // Label
          Text(label, style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary)),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.bodySmall()),
          ],
        ],
      ),
    );
  }
}

// ── Horizontal compact variant ───────────────────────────────────────────────
class StatSummaryRow extends StatelessWidget {
  final List<_StatItem> stats;

  const StatSummaryRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
            child: StatSummaryCard(
              label: e.value.label,
              value: e.value.value,
              icon: e.value.icon,
              color: e.value.color,
              subtitle: e.value.subtitle,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}