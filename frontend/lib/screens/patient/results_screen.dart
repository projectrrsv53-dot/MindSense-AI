// lib/screens/patient/results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/analysis_provider.dart';
import '../../models/analysis_result.dart';
// import '../../models/dummy_data.dart';
import '../../router/app_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/patient/result_chart.dart';
import '../../widgets/patient/analysis_card.dart';
import '../../widgets/common/emotion_pie_chart.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        backgroundColor: PatientColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('No results found', style: AppTextStyles.headingMedium()),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.patientDashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PatientColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: PatientColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
              onPressed: () => context.go(AppRoutes.patientDashboard),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: PatientColors.mainGradient),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Your Results 📊',
                        style: AppTextStyles.headingLarge(color: AppColors.white)),
                    const SizedBox(height: 4),
                    Text(
                      'AI-powered emotional analysis complete',
                      style: AppTextStyles.bodyMedium(color: AppColors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ── Overall Score Card ──────────────────────────
                  _OverallScoreCard(result: result),
                  const SizedBox(height: 16),

                  // ── Analysis detail ──────────────────────────────
                  AnalysisCard(result: result),
                  const SizedBox(height: 16),

// ── Emotion Distribution ─────────────────────────

                  Container(

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(

                      color: PatientColors.surface,

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(
                        color: PatientColors.divider,
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Emotion Distribution',
                          style: AppTextStyles.headingSmall(),
                        ),

                        const SizedBox(height: 24),

                        

                          

                            // ===================================
                            // DEPRESSION CHART
                            // ===================================

                             Column(

                                children: [

                                  Text(
                                    'Depression',
                                    style:
                                    AppTextStyles.bodyMedium(
                                      color:
                                      PatientColors.textSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  EmotionPieChart(

                                    positive:
                                    result
                                        .overallEmotionalScore,

                                    negative:
                                    100 -
                                        result
                                            .overallEmotionalScore,

                                    positiveLabel:
                                    'Non-Depressed',

                                    negativeLabel:
                                    'Depressed',
                                  ),
                                
                            

                            const SizedBox(width: 16),

                            // ===================================
                            // SENTIMENT CHART
                            // ===================================

                             

                                  Text(
                                    'Sentiment',
                                    style:
                                    AppTextStyles.bodyMedium(
                                      color:
                                      PatientColors.textSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  EmotionPieChart(

                                    positive:
                                    result.sentiment
                                        .isPositive
                                        ? result.sentiment
                                        .confidencePercent
                                        : 100 -
                                        result
                                            .sentiment
                                            .confidencePercent,

                                    negative:
                                    result.sentiment
                                        .isPositive
                                        ? 100 -
                                        result
                                            .sentiment
                                            .confidencePercent
                                        : result
                                        .sentiment
                                        .confidencePercent,

                                    positiveLabel:
                                    'Positive',

                                    negativeLabel:
                                    'Negative',
                                  ),
                                ],
                              ),
                            
                          
                        
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

// ── Mood trend chart ─────────────────────────────

                  Consumer(

                    builder: (
                        context,
                        ref,
                        _
                        ) {

                      final trendAsync =
                      ref.watch(
                        moodTrendProvider,
                      );

                      return trendAsync.when(

                        data: (trendData) {

                          return ResultChart(
                            moodData: trendData,
                          );
                        },

                        loading: () =>
                        const Center(
                          child:
                          CircularProgressIndicator(),
                        ),

                        error: (e, _) =>
                            Text(
                              'Trend load failed: $e',
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Recommendations ───────────────────────────────
                  _RecommendationsCard(result: result),
                  const SizedBox(height: 24),

                  // ── Action buttons ───────────────────────────────
                  PrimaryButton(
                    label: '👨‍⚕️  Share With My Doctor',
                    gradient: PatientColors.mainGradient,
                    onPressed: () => context.go('${AppRoutes.doctorConnect}?isUpload=true'),
                  ),
                  const SizedBox(height: 12),
                  OutlineButton(
                    label: 'Start New Analysis',
                    borderColor: PatientColors.primary,
                    textColor: PatientColors.primary,
                    onPressed: () {
                      ref.read(analysisProvider.notifier).reset();
                      context.go(AppRoutes.patientUpload);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallScoreCard extends StatelessWidget {
  final AnalysisResult result;

  const _OverallScoreCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result.overallEmotionalScore;
    Color scoreColor;
    String scoreLabel;

    if (score >= 65) {
      scoreColor = PatientColors.success;
      scoreLabel = 'Good';
    } else if (score >= 40) {
      scoreColor = PatientColors.warning;
      scoreLabel = 'Moderate';
    } else {
      scoreColor = PatientColors.error;
      scoreLabel = 'Needs Attention';
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: PatientColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PatientColors.divider),
      ),
      child: Row(
        children: [
          // Circle score
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: PatientColors.divider,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: AppTextStyles.headingLarge(color: scoreColor),
                    ),
                    Text('/100', style: AppTextStyles.bodySmall()),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Wellness', style: AppTextStyles.labelSmall()),
                const SizedBox(height: 4),
                Text(
                  scoreLabel,
                  style: AppTextStyles.headingMedium(color: PatientColors.textPrimary),
                ),
                const SizedBox(height: 8),
                StatusBadge(
                  label: result.sentiment.isPositive ? '😊 Positive Sentiment' : '😔 Negative Sentiment',
                  color: result.sentiment.isPositive
                      ? PatientColors.success
                      : PatientColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final AnalysisResult result;

  const _RecommendationsCard({required this.result});

  List<_Tip> get _tips {
    if (result.depression.isDepressed) {
      return const [
        _Tip('💬', 'Consider speaking to a mental health professional.'),
        _Tip('🌿', 'Try mindfulness or breathing exercises daily.'),
        _Tip('🚶', 'A short walk outdoors can help lift your mood.'),
        _Tip('👨‍⚕️', 'Share your results with a connected doctor.'),
      ];
    }
    return const [
      _Tip('🎉', 'Great job — keep maintaining your emotional health!'),
      _Tip('😴', 'Consistent sleep helps sustain positive wellbeing.'),
      _Tip('🤝', 'Stay connected with supportive people around you.'),
      _Tip('📓', 'Try journaling to track your emotional patterns.'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PatientColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PatientColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommendations', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 14),
          ..._tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.text,
                    style: AppTextStyles.bodyMedium(color: PatientColors.textSecondary),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Tip {
  final String emoji;
  final String text;
  const _Tip(this.emoji, this.text);
}