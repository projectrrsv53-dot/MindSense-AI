// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/dashboard_section_title.dart';
import '../../widgets/dashboard/dashboard_metric_card.dart';
import '../../widgets/dashboard/dashboard_quick_action_card.dart';
import '../../widgets/dashboard/dashboard_banner_card.dart';
import '../../models/doctor_verification_request.dart';
import '../../models/patient_model.dart';
import '../../widgets/admin/recent_activity_card.dart';
import '../../models/recent_activity.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final requestsAsync = ref.watch(pendingDoctorsProvider);
    final patientsAsync = ref.watch(adminPatientsProvider);
    final dashboardStats = ref.watch(adminDashboardStatsProvider);
    final verificationStats = ref.watch(verificationStatsProvider);
    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(pendingDoctorsProvider.notifier).loadPendingDoctors();
          ref.invalidate(adminPatientsProvider);
          ref.invalidate(recentActivityProvider);
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(verificationStatsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AdminColors.background,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: DashboardHeader(
                  title: 'Admin Dashboard 🛡️',
                  subtitle: auth.userEmail ?? 'admin@mindsense.ai',
                  gradient: AdminColors.mainGradient,
                  textColor: AppColors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.logout_rounded, color: AppColors.white, size: 20),
                  ),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go(AppRoutes.roleSelection);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Metrics ──────────────────────────────────────────
                  dashboardStats.when(
                    loading: () => _buildMetricLoading(),
                    error: (e, _) => Center(child: Text('Stats error: $e')),
                    data: (stats) {
                      return Row(
                        children: [
                          Expanded(child: DashboardMetricCard(label: "Pending", value: "${stats["pending_doctors"] ?? 0}", color: AdminColors.pending)),
                          const SizedBox(width: 12),
                          Expanded(child: DashboardMetricCard(label: "Approved", value: "${stats["approved_doctors"] ?? 0}", color: AdminColors.approved)),
                          const SizedBox(width: 12),
                          Expanded(child: DashboardMetricCard(label: "Patients", value: "${stats["patients"] ?? 0}", color: AdminColors.accent)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const DashboardSectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: '🛡️  Review Pending Verifications',
                    gradient: AdminColors.mainGradient,
                    height: 58,
                    onPressed: () => context.push(AppRoutes.adminVerifications),
                  ),
                  const SizedBox(height: 24),

                  const DashboardSectionTitle(title: 'Verification Activity'),
                  const SizedBox(height: 12),
                  verificationStats.when(
                    loading: () => _buildChartLoading(),
                    error: (e, _) => Center(child: Text('Chart error: $e')),
                    data: (stats) {
                      return _buildVerificationChart({
                        "approved": (stats["approved"] ?? 0).toInt(),
                        "pending": (stats["pending"] ?? 0).toInt(),
                        "rejected": (stats["rejected"] ?? 0).toInt(),
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  const DashboardSectionTitle(title: 'Pending Requests'),
                  const SizedBox(height: 12),
                  requestsAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                    error: (e, _) => _buildEmptyCard('Error loading requests'),
                    data: (requests) {
                      final pending = requests.where((r) => r.status == 'pending').toList();
                      if (pending.isEmpty) return _buildEmptyCard('No pending doctor requests');
                      return Column(
                        children: pending.take(3).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _VerificationCard(
                            request: r,
                            onApprove: () => _updateDoctorStatus(context, ref, r.id, 'approved'),
                            onReject: () => _updateDoctorStatus(context, ref, r.id, 'rejected'),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const DashboardSectionTitle(title: 'Recent Activity'),
                  const SizedBox(height: 12),
                  activityAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                    error: (e, _) => _buildEmptyCard('Unable to load activity'),
                    data: (activities) {
                      if (activities.isEmpty) return _buildEmptyCard('No recent activity');
                      return Column(
                        children: activities.take(5).map((RecentActivity a) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RecentActivityCard(activity: a),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  DashboardBannerCard(
                    emoji: '⚙️',
                    title: 'System Settings',
                    subtitle: 'Manage platform-wide configurations',
                    gradient: const LinearGradient(colors: [AdminColors.primary, AdminColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    onTap: () => context.push(AppRoutes.adminSettings),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricLoading() {
    return const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildChartLoading() {
    return Container(
      height: 220,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AdminColors.divider)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DashboardQuickActionCard(icon: '👨‍⚕️', label: 'Verify\nDoctors', color: AdminColors.accent, onTap: () => context.push(AppRoutes.adminVerifications))),
        const SizedBox(width: 12),
        Expanded(child: DashboardQuickActionCard(icon: '👥', label: 'Manage\nPatients', color: AdminColors.primary, onTap: () => context.push(AppRoutes.adminPatients))),
        const SizedBox(width: 12),
        Expanded(child: DashboardQuickActionCard(icon: '📄', label: 'System\nReports', color: AdminColors.primaryLight, onTap: () => context.push(AppRoutes.adminReports))),
      ],
    );
  }

  Widget _buildVerificationChart(Map<String, int> stats) {
    final approved = stats['approved']!.toDouble();
    final pending = stats['pending']!.toDouble();
    final rejected = stats['rejected']!.toDouble();
    final total = approved + pending + rejected;

    if (total == 0) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AdminColors.divider)),
        child: const Text("No verification data available"),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AdminColors.divider)),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 45,
                sectionsSpace: 3,
                borderData: FlBorderData(show: false),
                sections: [
                  PieChartSectionData(value: approved, color: AdminColors.approved, title: approved.toInt().toString(), radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: pending, color: AdminColors.pending, title: pending.toInt().toString(), radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: rejected, color: AdminColors.rejected, title: rejected.toInt().toString(), radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _legend(AdminColors.approved, "Approved (${approved.toInt()})"),
              _legend(AdminColors.pending, "Pending (${pending.toInt()})"),
              _legend(AdminColors.rejected, "Rejected (${rejected.toInt()})"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodySmall()),
      ],
    );
  }

  Future<void> _updateDoctorStatus(BuildContext context, WidgetRef ref, String id, String status) async {
    final success = await ref.read(pendingDoctorsProvider.notifier).updateStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Update successful' : 'Failed to update status')));
    }
  }

  Widget _buildEmptyCard(String message) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminColors.divider)), child: Center(child: Text(message, style: AppTextStyles.bodyMedium())));
  }
}

class _VerificationCard extends StatelessWidget {
  final DoctorVerificationRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _VerificationCard({required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AdminColors.primarySurface, child: Text(request.name[0])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(request.name, style: AppTextStyles.headingSmall()), Text(request.specialization, style: AppTextStyles.bodySmall())])),
              StatusBadge.verificationStatus(request.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onReject, style: OutlinedButton.styleFrom(foregroundColor: AdminColors.rejected, side: const BorderSide(color: AdminColors.rejected), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Reject'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: onApprove, style: ElevatedButton.styleFrom(backgroundColor: AdminColors.approved, foregroundColor: AppColors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Approve'))),
            ],
          ),
        ],
      ),
    );
  }
}
