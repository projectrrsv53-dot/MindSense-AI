// lib/screens/patient/patient_dashboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/dashboard_section_title.dart';
import '../../widgets/dashboard/dashboard_quick_action_card.dart';
import '../../widgets/dashboard/dashboard_banner_card.dart';
import '../../models/analysis_result.dart';
import '../../router/app_router.dart';
import '../../core/config/api_config.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends ConsumerState<PatientDashboardScreen> {
  String? selectedMood;
  List<dynamic> moodTrend = [];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final sessionsAsync = ref.watch(historyProvider);
    final isFirstTime = auth.isFirstTimeUser;
    final name = auth.userName ?? 'Friend';

    return Scaffold(
      backgroundColor: PatientColors.background,
      resizeToAvoidBottomInset: false, // PERFORMANCE: Prevent layout shift on keyboard
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: PatientColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 1: context.go('${AppRoutes.analysisDisclaimer}?type=fusion'); break;
            case 2: context.go(AppRoutes.patientHistory); break;
            case 3: context.go(AppRoutes.patientProfile); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "Analysis"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(historyProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: PatientColors.background,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: DashboardHeader(
                  title: 'Hello, $name 👋',
                  subtitle: 'How are you feeling today?',
                  gradient: PatientColors.cardGradient,
                  textColor: PatientColors.textPrimary,
                ),
              ),
              actions: [
                _buildAppBarAction(Icons.notifications_none_rounded, PatientColors.primary, () {}),
                _buildAppBarAction(Icons.logout_rounded, PatientColors.error, () {
                  ref.read(authProvider.notifier).logout();
                  context.go(AppRoutes.roleSelection);
                }),
                const SizedBox(width: 8),
              ],
            ),

            sessionsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
              data: (sessions) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMoodCard(),
                    const SizedBox(height: 24),

                    const DashboardSectionTitle(title: 'Analyse Now'),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 20),
                    _buildAppointmentButton(context),
                    const SizedBox(height: 32),

                    if (isFirstTime)
                      _buildFirstTimeHint()
                    else ...[
                      DashboardSectionTitle(title: 'Emotional Trend', actionLabel: 'View All', actionColor: PatientColors.primary, onActionPressed: () {}),
                      const SizedBox(height: 12),
                      RepaintBoundary(child: _buildTrendChart(sessions)),
                      const SizedBox(height: 32),

                      const DashboardSectionTitle(title: 'Recent Sessions'),
                      const SizedBox(height: 12),
                      ...sessions.take(5).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text("${s.analysisType.toUpperCase()} Submission", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Submitted: ${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year} • ${s.createdAt.hour}:${s.createdAt.minute.toString().padLeft(2, '0')}"),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Icon(s.doctorReviewed ? Icons.check_circle : Icons.schedule, size: 18, color: s.doctorReviewed ? Colors.green : Colors.orange),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        s.doctorReviewed ? "Reviewed" : "Awaiting Review",
                                        style: TextStyle(
                                          color: s.doctorReviewed ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.push("/patient/session/${s.sessionId}"),
                          ),
                        ),
                      )),
                    ],
                    
                    const SizedBox(height: 20),
                    DashboardBannerCard(
                      emoji: '👨‍⚕️',
                      title: 'Connect With a Doctor',
                      subtitle: 'Share your reports securely',
                      gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF7C6FCD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      onTap: () => context.go('${AppRoutes.doctorConnect}?isUpload=false'),
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
        decoration: BoxDecoration(color: PatientColors.surface, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 22, color: color),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildMoodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: PatientColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: PatientColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Mood Check', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['😢', '😕', '😐', '🙂', '😄'].map((emoji) {
                final isSelected = selectedMood == emoji;
                return GestureDetector(
                  onTap: () async {
                    try {
                      setState(() => selectedMood = emoji);
                      final auth = ref.read(authProvider);
                      await http.post(Uri.parse("${ApiConfig.baseUrl}/save-mood"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"patient_id": auth.userId, "mood": emoji})).timeout(const Duration(seconds: 5));
                    } catch (e) {
                      debugPrint("Mood save failed: $e");
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? Colors.deepPurple : Colors.transparent, width: 2),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 30)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: DashboardQuickActionCard(icon: '🎙️', label: 'Upload\nAudio', color: PatientColors.primary, onTap: () async {
              final auth = ref.read(authProvider);
              final response = await http.get(Uri.parse(ApiConfig.myDoctors(auth.userId!)));
              final data = jsonDecode(response.body);
              if ((data["doctors"] as List).isEmpty) { context.go('${AppRoutes.doctorConnect}?isUpload=false'); return; }
              context.go('${AppRoutes.analysisDisclaimer}?type=fusion');
            })),
            const SizedBox(width: 12),
            Expanded(child: DashboardQuickActionCard(icon: '📝', label: 'Upload\nDiary', color: PatientColors.accent, onTap: () async {
              final auth = ref.read(authProvider);
              final response = await http.get(Uri.parse(ApiConfig.myDoctors(auth.userId!)));
              final data = jsonDecode(response.body);
              if ((data["doctors"] as List).isEmpty) { context.go('${AppRoutes.doctorConnect}?isUpload=false'); return; }
              context.go('${AppRoutes.analysisDisclaimer}?type=text');
            })),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: DashboardQuickActionCard(icon: '👨‍⚕️', label: 'Connect\nDoctor', color: const Color(0xFF9B59B6), onTap: () => context.go('${AppRoutes.doctorConnect}?isUpload=false'))),
            const SizedBox(width: 12),
            Expanded(child: DashboardQuickActionCard(icon: '📅', label: 'Book\nAppointment', color: Colors.teal, onTap: () => context.go(AppRoutes.appointment))),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.patientAppointments),
      child: Container(
        width: double.infinity, height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFF9C6BFF)], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("🗓️", style: TextStyle(fontSize: 22)),
              SizedBox(width: 12),
              Flexible(child: Text("Upcoming Appointments", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<dynamic> sessions) {
    if (sessions.isEmpty) return const Center(child: Text("No data"));
    final recentSessions = sessions.take(10).toList();
    return Container(
      height: 160, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: PatientColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: PatientColors.divider)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: PatientColors.divider, strokeWidth: 1)),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(recentSessions.length, (index) => FlSpot(index.toDouble(), recentSessions[index].score)),
              isCurved: true, gradient: const LinearGradient(colors: [PatientColors.primary, PatientColors.accent]),
              barWidth: 3, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [PatientColors.primary.withValues(alpha: 0.15), PatientColors.accent.withValues(alpha: 0.02)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
          ],
          minY: 0, maxY: 100,
        ),
      ),
    );
  }

  Widget _buildFirstTimeHint() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: PatientColors.cardGradient, borderRadius: BorderRadius.circular(18), border: Border.all(color: PatientColors.divider)),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text('Your First Session', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 8),
          Text('Start by uploading an audio recording or transcript. Your emotional wellness journey begins here.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium()),
        ],
      ),
    );
  }
}
