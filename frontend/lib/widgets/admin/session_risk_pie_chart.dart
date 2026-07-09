// lib/widgets/admin/session_risk_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SessionRiskPieChart extends StatelessWidget {
  final int critical;
  final int high;
  final int medium;
  final int low;

  const SessionRiskPieChart({
    super.key,
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    final total = critical + high + medium + low;

    if (total == 0) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        child: Text(
          "No session data available",
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
            "Session Risk Distribution",
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
                    value: critical.toDouble(),
                    color: Colors.red,
                    title: critical.toString(),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: high.toDouble(),
                    color: Colors.deepOrange,
                    title: high.toString(),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: medium.toDouble(),
                    color: Colors.amber,
                    title: medium.toString(),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: low.toDouble(),
                    color: Colors.green,
                    title: low.toString(),
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
            spacing: 18,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [

              _Legend(
                color: Colors.red,
                text: "Critical ($critical)",
              ),

              _Legend(
                color: Colors.deepOrange,
                text: "High ($high)",
              ),

              _Legend(
                color: Colors.amber,
                text: "Medium ($medium)",
              ),

              _Legend(
                color: Colors.green,
                text: "Low ($low)",
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