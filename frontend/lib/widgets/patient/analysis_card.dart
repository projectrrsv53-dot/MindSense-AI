// lib/widgets/patient/analysis_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/analysis_result.dart';

class AnalysisCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback? onTap;

  const AnalysisCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dep = result.depression;
    final sent = result.sentiment;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PatientColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PatientColors.divider),
          boxShadow: [
            BoxShadow(
              color: PatientColors.primary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dep.isDepressed
                        ? PatientColors.error.withValues(alpha: 0.1)
                        : PatientColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      dep.isDepressed ? '⚠️' : '✅',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Analysis',
                        style: AppTextStyles.headingSmall(),
                      ),
                      Text(
                        _formatDate(result.timestamp),
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: PatientColors.textHint,
                  ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: PatientColors.divider, height: 1),
            const SizedBox(height: 14),

            // Depression result
            _ResultRow(
              label: 'Emotional State',
              value: dep.safeDisplayLabel,
              confidence: dep.confidencePercent,
              color: dep.isDepressed ? PatientColors.error : PatientColors.success,
            ),
            const SizedBox(height: 10),

            // Sentiment result
            _ResultRow(
              label: 'Sentiment',
              value: sent.isPositive ? 'Positive expression' : 'Negative expression',
              confidence: sent.confidencePercent,
              color: sent.isPositive ? PatientColors.success : PatientColors.warning,
            ),

            const SizedBox(height: 14),

            // Transcript preview
            if (result.transcriptPreview.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PatientColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: PatientColors.textHint, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.transcriptPreview,
                        style: AppTextStyles.bodySmall(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final double confidence;
  final Color color;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.confidence,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall()),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium(color: PatientColors.textPrimary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${confidence.toStringAsFixed(1)}%',
            style: AppTextStyles.labelSmall(color: color),
          ),
        ),
      ],
    );
  }
}
