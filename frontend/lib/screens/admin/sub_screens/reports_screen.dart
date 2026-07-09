// lib/screens/admin/sub_screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/admin/report_summary_card.dart';
import '../../../widgets/admin/session_risk_pie_chart.dart';
import '../../../widgets/admin/analysis_type_pie_chart.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsAnalyticsProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports & Analytics', style: AppTextStyles.headingMedium()),
            Text('System insights and statistics', style: AppTextStyles.bodySmall()),
          ],
        ),
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(reportsAnalyticsProvider),
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _buildErrorState(ref),
          data: (data) {
            if (data.isEmpty) return _buildEmptyState();

            final riskDist = data['risk_distribution'] ?? {};
            final typeDist = data['analysis_types'] ?? {};

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // --- Summary Cards ---
                _buildSummaryGrid(data),
                const SizedBox(height: 24),

                // --- Session Risk Distribution ---
                SessionRiskPieChart(
                  critical: (riskDist['CRITICAL'] ?? 0).toInt(),
                  high: (riskDist['HIGH'] ?? 0).toInt(),
                  medium: (riskDist['MEDIUM'] ?? 0).toInt(),
                  low: (riskDist['LOW'] ?? 0).toInt(),
                ),
                const SizedBox(height: 24),

                // --- Analysis Type Distribution ---
                AnalysisTypePieChart(
                  textCount: (typeDist['TEXT'] ?? 0).toInt(),
                  audioCount: (typeDist['AUDIO'] ?? 0).toInt(),
                  fusionCount: (typeDist['FUSION'] ?? 0).toInt(),
                ),
                const SizedBox(height: 24),

                // --- Daily Sessions (Coming Soon / Placeholder) ---
                _buildDailySessionsChart(),
                const SizedBox(height: 24),

                // --- Doctor Workload ---
                _buildDoctorWorkload(data['doctor_workload']),
                const SizedBox(height: 24),

                // --- Export Section ---
                _buildExportSection(context),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> data) {
    final riskDist = data['risk_distribution'] ?? {};
    return Column(
      children: [
        ReportSummaryCard(
          title: 'Total Sessions',
          value: '${data['total_sessions'] ?? 0}',
          icon: Icons.analytics_outlined,
          color: AdminColors.accent,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Critical',
                value: '${riskDist['CRITICAL'] ?? 0}',
                icon: Icons.report_gmailerrorred_rounded,
                color: AdminColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportSummaryCard(
                title: 'High Risk',
                value: '${riskDist['HIGH'] ?? 0}',
                icon: Icons.warning_amber_rounded,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Medium',
                value: '${riskDist['MEDIUM'] ?? 0}',
                icon: Icons.info_outline_rounded,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportSummaryCard(
                title: 'Low Risk',
                value: '${riskDist['LOW'] ?? 0}',
                icon: Icons.check_circle_outline_rounded,
                color: AdminColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailySessionsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Activity Trend', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 20),
          Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.show_chart_rounded, size: 40, color: AdminColors.textHint),
                const SizedBox(height: 8),
                Text('Activity Analytics Coming Soon', style: AppTextStyles.bodySmall()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorWorkload(dynamic workload) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Doctor Engagement', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 16),
          if (workload == null)
            Text('Doctor workload analytics coming soon.', style: AppTextStyles.bodySmall())
          else
            const Text('Workload data present'), // Handle list if available
        ],
      ),
    );
  }

  Widget _buildExportSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.table_view_outlined),
            label: const Text('Export CSV'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AdminColors.error),
          const SizedBox(height: 16),
          Text('Unable to load reports.', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.refresh(reportsAnalyticsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: AdminColors.textHint),
          const SizedBox(height: 16),
          Text('No reports available.', style: AppTextStyles.headingSmall()),
        ],
      ),
    );
  }
}
