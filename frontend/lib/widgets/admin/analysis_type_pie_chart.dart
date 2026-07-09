// lib/widgets/admin/analysis_type_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AnalysisTypePieChart extends StatelessWidget {
  final int textCount;
  final int audioCount;
  final int fusionCount;

  const AnalysisTypePieChart({
    super.key,
    required this.textCount,
    required this.audioCount,
    required this.fusionCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = textCount + audioCount + fusionCount;

    if (total == 0) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        child: Text(
          "No analysis data available",
          style: AppTextStyles.bodyMedium(
            color: AdminColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AdminColors.divider,
        ),
      ),
      child: Column(
        children: [

          Text(
            "Analysis Type Distribution",
            style: AppTextStyles.headingSmall(),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 55,
                sectionsSpace: 3,
                borderData: FlBorderData(show: false),

                sections: [

                  PieChartSectionData(
                    value: textCount.toDouble(),
                    color: Colors.blue,
                    title: textCount.toString(),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: audioCount.toDouble(),
                    color: Colors.orange,
                    title: audioCount.toString(),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: fusionCount.toDouble(),
                    color: Colors.green,
                    title: fusionCount.toString(),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [

              _Legend(
                color: Colors.blue,
                text: "Text ($textCount)",
              ),

              _Legend(
                color: Colors.orange,
                text: "Audio ($audioCount)",
              ),

              _Legend(
                color: Colors.green,
                text: "Fusion ($fusionCount)",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          text,
          style: AppTextStyles.bodySmall(),
        ),
      ],
    );
  }
}