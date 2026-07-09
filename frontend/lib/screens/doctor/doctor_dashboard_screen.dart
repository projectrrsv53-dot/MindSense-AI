// lib/screens/doctor/doctor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/dashboard_section_title.dart';
import '../../widgets/dashboard/dashboard_metric_card.dart';
import '../../widgets/dashboard/dashboard_quick_action_card.dart';
import '../../widgets/dashboard/dashboard_banner_card.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/doctor_availability_provider.dart';
import '../../models/doctor_alert.dart';
import '../../services/api_service.dart';
import '../../utils/risk_helper.dart';
import '../../widgets/doctor/patient_list_card.dart';
import '../../models/patient_model.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final patientsAsync = ref.watch(doctorPatientsProvider);
    final alertsAsync = ref.watch(doctorAlertsProvider);
    final riskData = ref.watch(doctorRiskDistributionProvider);
    final name = auth.userName ?? 'Doctor';

    // Redirection logic using ref.listen to avoid side-effects in build
    ref.listen(doctorAvailabilityProvider(auth.userId ?? ''), (previous, next) {
      next.whenData((availability) {
        if (availability["availability_configured"] != true) {
          context.go(AppRoutes.doctorAvailability);
        }
      });
    });

    return Scaffold(
      backgroundColor: DoctorColors.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: DoctorColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.doctorDashboard);
              break;
            case 1:
              context.go(AppRoutes.patientList);
              break;
            case 2:
              context.push(AppRoutes.doctorAppointments);
              break;
            case 3:
              context.go(AppRoutes.doctorProfile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(doctorPatientsProvider);
          ref.invalidate(doctorAlertsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: DoctorColors.background,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: DashboardHeader(
                  title: 'Hello, $name 👋',
                  subtitle: 'Clinical Dashboard',
                  gradient: DoctorColors.cardGradient,
                  textColor: DoctorColors.textPrimary,
                ),
              ),
              actions: [
                _buildAppBarAction(Icons.notifications_none_rounded, DoctorColors.textPrimary, () {}),
                _buildAppBarAction(Icons.logout_rounded, DoctorColors.error, () {
                  ref.read(authProvider.notifier).logout();
                  context.go(AppRoutes.roleSelection);
                }),
                const SizedBox(width: 8),
              ],
            ),

            patientsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Error: ${error.toString()}')),
              ),
              data: (patients) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Metrics ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: DashboardMetricCard(label: 'Total Patients', value: '${patients.length}', icon: Icons.people_rounded, color: DoctorColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: DashboardMetricCard(label: 'High Risk', value: '${riskData['high']}', icon: Icons.warning_amber_rounded, color: DoctorColors.highRisk)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Quick Actions ─────────────────────────────────────
                    const DashboardSectionTitle(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _buildQuickActionGrid(context),
                    const SizedBox(height: 24),

                    // ── Critical Alerts ──────────────────────────────────
                    const DashboardSectionTitle(title: 'Critical Alerts'),
                    const SizedBox(height: 12),
                    alertsAsync.maybeWhen(
                      data: (alerts) {
                        final unresolved = alerts.where((a) => !a.isResolved).toList();
                        if (unresolved.isEmpty) return _buildEmptyAlerts();
                        return Column(
                          children: unresolved.take(3).map((alert) => _buildAlertCard(context, ref, alert)).toList(),
                        );
                      },
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                      orElse: () => _buildEmptyAlerts(),
                    ),
                    const SizedBox(height: 24),

                    PrimaryButton(
                      label: '📋  Review Patient Reports',
                      gradient: DoctorColors.mainGradient,
                      height: 58,
                      onPressed: () => context.go(AppRoutes.patientList),
                    ),
                    const SizedBox(height: 32),

                    // ── Patient Risk Distribution Chart ──────────────────────────
                    const DashboardSectionTitle(title: 'Patient Risk Distribution'),
                    const SizedBox(height: 12),
                    RepaintBoundary(child: _buildRiskChart(riskData['high']!, riskData['low']!)),
                    const SizedBox(height: 32),
                    // ── Recent Patients ──────────────────────────
                    const DashboardSectionTitle(
                      title: 'Recent Patients',
                    ),

                    const SizedBox(height: 12),

                    _buildRecentPatients(
                      context,
                      patients,
                    ),

                    const SizedBox(height: 24),
                    
                    const SizedBox(height: 20),
                    DashboardBannerCard(
                      emoji: '🏥',
                      title: 'Clinical Support',
                      subtitle: 'Immediate attention for high-risk patients',
                      gradient: const LinearGradient(colors: [DoctorColors.highRisk, DoctorColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      onTap: () {},
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: DoctorColors.surface, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildEmptyAlerts() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: DoctorColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.success.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: DoctorColors.success),
          const SizedBox(height: 8),
          Text('No pending critical alerts', style: AppTextStyles.bodySmall(color: DoctorColors.success)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, DoctorAlert alert) {
    final Color riskColor = AppColors.getRiskColor(alert.riskLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getRiskBackground(alert.riskLevel),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: riskColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.patientName,
                  style: AppTextStyles.bodyMedium(color: DoctorColors.textPrimary).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: AppTextStyles.bodySmall(color: DoctorColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    try {
                      await ApiService().resolveAlert(alert.id);
                      ref.invalidate(doctorAlertsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert resolved')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resolve alert: $e')));
                      }
                    }
                  },
                  child: Text('Mark as Resolved', style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: DoctorColors.textHint),
            onPressed: () => context.push(AppRoutes.doctorSessionDetails.replaceFirst(':sessionId', alert.sessionId)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: DashboardQuickActionCard(icon: '👥', label: 'All Patients', color: DoctorColors.primary, onTap: () => context.go(AppRoutes.patientList))),
            const SizedBox(width: 12),
            Expanded(child: DashboardQuickActionCard(icon: '🚨', label: 'High Risk', color: DoctorColors.highRisk, onTap: () => context.go(AppRoutes.patientList,extra: {
              "filter": "highRisk",
            },))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: DashboardQuickActionCard(icon: '🕒', label: 'Availability', color: DoctorColors.accent, onTap: () => context.go(AppRoutes.doctorAvailability))),
            const SizedBox(width: 12),
            Expanded(child: DashboardQuickActionCard(icon: '📅', label: 'Appointments', color: const Color(0xFF9B59B6), onTap: () => context.push(AppRoutes.doctorAppointments))),
          ],
        ),
      ],
    );
  }

  // Widget _buildRiskChart(int high, int low) {
  //   if ((high + low) == 0) return const SizedBox.shrink();
  //   return Container(
  //     height: 200,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(color: DoctorColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: DoctorColors.divider)),
  //     child: PieChart(
  //       PieChartData(
  //         sectionsSpace: 4,
  //         centerSpaceRadius: 35,
  //         sections: [
  //           PieChartSectionData(value: high.toDouble(), title: 'High', color: DoctorColors.highRisk, radius: 45, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
  //           PieChartSectionData(value: low.toDouble(), title: 'Low', color: DoctorColors.lowRisk, radius: 45, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildRiskChart(int high, int low) {
    if ((high + low) == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Column(
        children: [

          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: high.toDouble(),
                    title: '$high',
                    color: DoctorColors.highRisk,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: low.toDouble(),
                    title: '$low',
                    color: DoctorColors.lowRisk,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              _buildLegendItem(
                DoctorColors.highRisk,
                "High Risk",
                high,
              ),

              _buildLegendItem(
                DoctorColors.lowRisk,
                "Low Risk",
                low,
              ),

            ],
          ),
        ],
      ),
    );
  }
  Widget _buildLegendItem(
      Color color,
      String label,
      int value,
      ) {
    return Row(
      children: [

        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          "$label ($value)",
          style: AppTextStyles.bodySmall(
            color: DoctorColors.textPrimary,
          ),
        ),

      ],
    );
  }
  Widget _buildRecentPatients(
      BuildContext context,
      List<PatientModel> patients,
      ) {
    if (patients.isEmpty) {
      return const Center(
        child: Text("No patients found."),
      );
    }

    final recentPatients = [...patients];

    recentPatients.sort(
          (a, b) => b.joinedDate.compareTo(a.joinedDate),
    );

    return Column(
      children: recentPatients
          .take(5)
          .map(
            (patient) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PatientListCard(
            patient: patient,
            onTap: () {
              context.push(
                AppRoutes.doctorPatientDetails.replaceFirst(
                  ':patientId',
                  patient.patientId,
                ),
              );
            },
          ),
        ),
      )
          .toList(),
    );
  }
}
