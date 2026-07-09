// lib/widgets/doctor/analytics_detail.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
//import '../../models/dummy_data.dart';
import '../common/status_badge.dart';
import '../../models/analysis_result.dart';

class AnalyticsDetail extends StatelessWidget {
  //final PatientModel patient;
  final List<AnalysisResult> sessions;
  //const AnalyticsDetail({super.key, required this.patient});
  const AnalyticsDetail({
    super.key,
    required this.sessions,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRiskSummary(),
        const SizedBox(height: 16),
        _buildTrendChart(),
        const SizedBox(height: 16),
        _buildSessionHistory(),
      ],
    );
  }

  // ── Risk Summary Banner ─────────────────────────────────────────────────
  Widget _buildRiskSummary() {
    final hasHighRisk = sessions.any(
          (s) => s.depression.isDepressed,
    );
    final riskLevel = hasHighRisk
        ? 'High Risk'
        : 'Low Risk';
    Color riskColor;
    String riskEmoji;
    switch (riskLevel) {
      case 'High Risk':
        riskColor = DoctorColors.highRisk;
        riskEmoji = '🔴';
        break;
      case 'Moderate Risk':
        riskColor = DoctorColors.warning;
        riskEmoji = '🟡';
        break;
      default:
        riskColor = DoctorColors.lowRisk;
        riskEmoji = '🟢';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(riskEmoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Risk Assessment',
                    style: AppTextStyles.labelSmall(color: riskColor)),
                const SizedBox(height: 4),
                Text(riskLevel,
                    style: AppTextStyles.headingMedium(color: DoctorColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  'Based on ${sessions.length} session(s)',
                  style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusBadge.risk(riskLevel),
        ],
      ),
    );
  }

  // ── Trend Chart ────────────────────────────────────────────────────────
  Widget _buildTrendChart() {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DoctorColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DoctorColors.divider),
        ),
        child: Center(
          child: Text('No session data yet', style: AppTextStyles.bodyMedium()),
        ),
      );
    }

    final reversed = sessions.reversed.toList();
    final spots = reversed.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.overallEmotionalScore);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wellness Score Trend', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                  const FlLine(color: DoctorColors.divider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) =>
                          Text(v.toInt().toString(), style: AppTextStyles.bodySmall()),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= reversed.length) return const SizedBox.shrink();
                        final diff = DateTime.now()
                            .difference(reversed[idx].timestamp)
                            .inDays;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            diff == 0 ? 'Today' : '${diff}d',
                            style: AppTextStyles.bodySmall(),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (reversed.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: DoctorColors.mainGradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, x, painter, y) => FlDotCirclePainter(
                        radius: 5,
                        color: DoctorColors.primary,
                        strokeWidth: 2,
                        strokeColor: DoctorColors.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          DoctorColors.primary.withOpacity(0.15),
                          DoctorColors.accent.withOpacity(0.03),
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

  // ── Session History List ───────────────────────────────────────────────
  Widget _buildSessionHistory() {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session History', style: AppTextStyles.headingSmall()),
        const SizedBox(height: 12),
        ...sessions.map((AnalysisResult s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SessionRow(session: s),
        )),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final AnalysisResult session;

  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final dep = session.depression;
    final sent = session.sentiment;
    final diff = DateTime.now().difference(session.timestamp).inDays;
    final dateLabel = diff == 0 ? 'Today' : diff == 1 ? 'Yesterday' : '${diff}d ago';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DoctorColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: dep.isDepressed
                  ? DoctorColors.highRisk.withOpacity(0.1)
                  : DoctorColors.lowRisk.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                dep.isDepressed ? '⚠️' : '✅',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dep.safeDisplayLabel,
                    style: AppTextStyles.bodyMedium(color: DoctorColors.textPrimary)),
                Text(
                  'Sentiment: ${sent.label} (${sent.confidenceDisplay})',
                  style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.overallEmotionalScore.toStringAsFixed(0),
                style: AppTextStyles.headingSmall(color: DoctorColors.primary),
              ),
              Text(dateLabel, style: AppTextStyles.bodySmall()),
            ],
          ),
        ],
      ),
    );
  }
}