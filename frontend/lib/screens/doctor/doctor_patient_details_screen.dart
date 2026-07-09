// lib/screens/doctor/doctor_patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/doctor_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/patient/result_chart.dart';
import '../../models/mood_point.dart';
import '../../models/analysis_result.dart';

class DoctorPatientDetailsScreen extends ConsumerWidget {
  final String patientId;

  const DoctorPatientDetailsScreen({super.key, required this.patientId});
  
  // PERFORMANCE: Cache mood mapping to avoid redundant logic in build
  static final Map<String, double> _moodScores = {
    '😁': 100, '😊': 80, '🙂': 65, '😐': 50, '😕': 30, '😢': 10,
  };

  double _moodToScore(String mood) => _moodScores[mood] ?? 50;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailsProvider(patientId));
    final moodsAsync = ref.watch(patientMoodProvider(patientId));
    final List<AnalysisResult> sessions = ref.watch(processedPatientSessionsProvider(patientId));

    return Scaffold(
      backgroundColor: DoctorColors.background,
      resizeToAvoidBottomInset: false, // PERFORMANCE: Prevent layout shift on keyboard
      appBar: AppBar(
        backgroundColor: DoctorColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: DoctorColors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.doctorDashboard),
        ),
        title: Text('Patient Profile', style: AppTextStyles.headingMedium()),
        centerTitle: true,
      ),

      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: DoctorColors.error),
              const SizedBox(height: 16),
              Text('Error loading details', style: AppTextStyles.headingSmall()),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Retry', width: 120, onPressed: () =>
                  ref.invalidate(patientDetailsProvider(patientId))),

            ],
          ),
        ),
        data: (data) {
          final patient = (data['patient'] as Map<String, dynamic>?) ?? {};
          final emergencyContacts = ((data['emergency_contacts'] as List?) ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          
          if (patient.isEmpty) return const Center(child: Text('Patient not found'));

          final List<MoodPoint> moodTrend = (moodsAsync.value ?? []).map((m) {
            final timestamp = DateTime.tryParse(m["timestamp"]?.toString() ?? "") ?? DateTime.now();
            return MoodPoint(day: DateFormat('MMM dd').format(timestamp), score: _moodToScore(m["mood"]?.toString() ?? "😐"));
          }).toList().reversed.take(7).toList();

          final List<MoodPoint> depressionTrend = sessions.take(10).map((AnalysisResult s) {
            return MoodPoint(day: DateFormat('MMM dd').format(s.timestamp), score: s.overallEmotionalScore);
          }).toList().reversed.toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(patientDetailsProvider(patientId));
              ref.invalidate(patientMoodProvider(patientId));
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileCard(patient, emergencyContacts),
                      const SizedBox(height: 24),

                      Text('Mood Check-in Trend', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 14),
                      RepaintBoundary(
                        child: moodTrend.isNotEmpty 
                          ? ResultChart(moodData: moodTrend) 
                          : _buildEmptyState('No mood data available')
                      ),

                      const SizedBox(height: 24),
                      Text('AI Wellness Trend', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 14),
                      RepaintBoundary(
                        child: depressionTrend.isNotEmpty 
                          ? ResultChart(moodData: depressionTrend, title: 'Wellness Score (Higher is Better)') 
                          : _buildEmptyState('No analysis data available')
                      ),

                      const SizedBox(height: 24),
                      Text('Primary Concerns', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 12),
                      _buildConcerns(patient['primary_concerns'] as List? ?? []),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Analysis History', style: AppTextStyles.headingSmall()),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: DoctorColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                            child: Text('${sessions.length} Sessions', style: AppTextStyles.labelSmall(color: DoctorColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                if (sessions.isEmpty)
                  SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _buildEmptyState('No session data yet')))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SessionSummaryCard(session: sessions[index]),
                        ),
                        childCount: sessions.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> patient, List<Map<String, dynamic>> emergencyContacts) {
    final String name = (patient['name'] ?? 'Unknown').toString();
    final String email = (patient['email'] ?? '').toString();
    
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DoctorColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: DoctorColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 38, 
                backgroundColor: DoctorColors.primarySurface, 
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: AppTextStyles.headingLarge(color: DoctorColors.primary))
              ),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: AppTextStyles.headingMedium()),
                const SizedBox(height: 4),
                Text(email, style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary)),
              ])),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildInfoItem('Age', '${patient['age'] ?? 'N/A'}'),
            _buildInfoItem('Gender', patient['gender'] ?? 'N/A'),
          ]),
          if (emergencyContacts.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Text("Emergency Contacts", style: AppTextStyles.headingSmall()),
            const SizedBox(height: 12),
            ...emergencyContacts.map((contact) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.contact_phone, color: Colors.red, size: 20),
              title: Text(contact["name"] ?? "", style: AppTextStyles.bodyMedium(color: DoctorColors.textPrimary)),
              subtitle: Text(
                "${contact["relationship"] ?? ""} • ${contact["phone"] ?? ""}\n"
                "${contact["email"] ?? ""}",
                style: AppTextStyles.bodySmall(),
              ),
            )),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(children: [
      Text(label, style: AppTextStyles.bodySmall(color: DoctorColors.textHint)),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.bodyMedium(color: DoctorColors.textPrimary).copyWith(fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildConcerns(List concerns) {
    if (concerns.isEmpty) return Text('No concerns listed', style: AppTextStyles.bodySmall());
    return Wrap(spacing: 8, runSpacing: 8, children: concerns.map((c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: DoctorColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(c.toString(), style: AppTextStyles.bodySmall(color: DoctorColors.accent).copyWith(fontWeight: FontWeight.w600)),
    )).toList());
  }

  Widget _buildEmptyState(String message) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: DoctorColors.cardBg, borderRadius: BorderRadius.circular(16)), child: Center(child: Text(message, style: AppTextStyles.bodySmall())));
  }
}

class _SessionSummaryCard extends StatelessWidget {
  final AnalysisResult session;
  const _SessionSummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(session.timestamp);
    final isDepressed = session.depression.isDepressed;
    final riskLabel = session.riskLevel.toUpperCase();
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.doctorSessionDetails.replaceFirst(':sessionId', session.sessionId)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DoctorColors.surface, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: DoctorColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                isDepressed ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
                color: isDepressed ? DoctorColors.highRisk : DoctorColors.lowRisk,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDepressed ? "Higher Risk Indicators" : "Emotional Balance Stable",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(
                            riskLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: riskLabel == "CRITICAL" || riskLabel == "DEPRESSED" || riskLabel == "HIGH"
                                  ? Colors.red
                                  : riskLabel == "MODERATE"
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (riskLabel == "CRITICAL" && !session.doctorReviewed)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 6, height: 6,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                        const SizedBox(width: 4),
                        Flexible(
                          flex: 2,
                          child: Text(
                            session.doctorReviewed ? "• Reviewed" : "• Pending Review",
                            style: TextStyle(
                              fontSize: 10,
                              color: session.doctorReviewed ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(dateStr, style: AppTextStyles.bodySmall(color: DoctorColors.textHint)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${session.overallEmotionalScore.toStringAsFixed(0)}%', 
                      style: TextStyle(
                        color: session.overallEmotionalScore < 40 ? DoctorColors.error : DoctorColors.primary, 
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Text('Wellness', style: TextStyle(fontSize: 8, color: DoctorColors.textHint)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: DoctorColors.divider, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
