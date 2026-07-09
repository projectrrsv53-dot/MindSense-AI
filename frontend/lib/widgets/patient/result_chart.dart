// lib/widgets/patient/result_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/mood_point.dart';

class ResultChart extends StatelessWidget {
  final List<MoodPoint> moodData;
  final String title;

  const ResultChart({
    super.key,
    required this.moodData,
    this.title = 'Mood Trend (7 Days)',
  });

  @override
  Widget build(BuildContext context) {
    if (moodData.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: Text('No trend data available', style: AppTextStyles.bodySmall()),
      );
    }

    final double maxX = moodData.length > 1 ? (moodData.length - 1).toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PatientColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PatientColors.divider),
        boxShadow: [
          BoxShadow(
            color: PatientColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headingSmall()),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: PatientColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: AppTextStyles.bodySmall(),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= moodData.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            moodData[idx].day,
                            style: AppTextStyles.bodySmall(),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: moodData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.score);
                    }).toList(),
                    isCurved: moodData.length > 1,
                    curveSmoothness: 0.35,
                    gradient: const LinearGradient(
                      colors: [PatientColors.primary, PatientColors.accent],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: PatientColors.primary,
                        strokeWidth: 2,
                        strokeColor: PatientColors.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          PatientColors.primary.withValues(alpha: 0.12),
                          PatientColors.accent.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
