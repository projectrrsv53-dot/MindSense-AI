// lib/widgets/common/emotion_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmotionPieChart extends StatelessWidget {

  final double positive;
  final double negative;
  final String positiveLabel;
  final String negativeLabel;

  const EmotionPieChart({
    super.key,
    required this.positive,
    required this.negative,
    required this.positiveLabel,
    required this.negativeLabel,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      height: 240, // Reduced height for better performance on mobile
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(

                sectionsSpace: 3,

                centerSpaceRadius: 38,

                sections: [

                  PieChartSectionData(

                    value: positive,

                    color: const Color(
                      0xFF4FD1C5,
                    ),

                    radius: 38,

                    title:
                    '${positive.toStringAsFixed(1)}%',

                    titleStyle: const TextStyle(

                      fontSize: 14,

                      fontWeight:
                      FontWeight.bold,

                      color: Colors.white,
                    ),
                  ),

                  PieChartSectionData(

                    value: negative,

                    color: const Color(
                      0xFFFF8A65,
                    ),

                    radius: 38,

                    title:
                    '${negative.toStringAsFixed(1)}%',

                    titleStyle: const TextStyle(

                      fontSize: 14,

                      fontWeight:
                      FontWeight.bold,

                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
  alignment: WrapAlignment.center,
  spacing: 20,
  runSpacing: 8,
  children: [
    _legend(
      color: const Color(0xFF4FD1C5),
      text: positiveLabel,
    ),
    _legend(
      color: const Color(0xFFFF8A65),
      text: negativeLabel,
    ),
  ],
)
        ],
      ),
    );
  }

  Widget _legend({
    required Color color,
    required String text,
  }) {

    return Row(
      children: [

        Container(
          width: 12,
          height: 12,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}