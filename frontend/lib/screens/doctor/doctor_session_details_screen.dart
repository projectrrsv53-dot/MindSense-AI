// lib/screens/doctor/doctor_session_details_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/doctor_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/patient/analysis_card.dart';
import '../../widgets/common/emotion_pie_chart.dart';
import '../../models/analysis_result.dart';
import '../../providers/auth_provider.dart';
import '../../services/doctor_service.dart';

class DoctorSessionDetailsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const DoctorSessionDetailsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<DoctorSessionDetailsScreen> createState() => _DoctorSessionDetailsScreenState();
}

class _DoctorSessionDetailsScreenState extends ConsumerState<DoctorSessionDetailsScreen> {
  final TextEditingController feedbackController = TextEditingController();
  bool initialized = false;
  bool isEditing = false;
  bool requiresEmergencyContact = false;

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.read(sessionDetailsProvider(widget.sessionId));
    final auth = ref.read(authProvider);

    final doctorId = auth.userId ?? '';
    final doctorName = auth.userName ?? 'Doctor';

    return Scaffold(
      backgroundColor: DoctorColors.background,
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Scaffold(
          appBar: AppBar(backgroundColor: DoctorColors.background, elevation: 0),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: DoctorColors.error),
                const SizedBox(height: 16),
                Text('Error loading session', style: AppTextStyles.headingSmall()),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Retry',
                  width: 120,
                  onPressed: () => ref.refresh(sessionDetailsProvider(widget.sessionId)),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          // Extract backend fields
          final bool reviewed = data['doctor_reviewed'] ?? false;
          final String doctorFeedback = data['doctor_feedback'] ?? '';
          final String analysisType =
          (data["analysis_type"] ?? "").toString().toLowerCase();
          // final String transcript = data['transcript'] ?? '';
          final String transcript = analysisType == "text"
              ? (data["original_text"] ?? "")
              : (data["transcript"] ?? "");
          final String? audioUrl = data['audio_url'];

          // Initialize feedbackController only once
          if (!initialized) {
            feedbackController.text = doctorFeedback;
            initialized = true;
          }

          // Convert backend data to AnalysisResult model
          final result = AnalysisResult.fromBackend(data);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ───────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: DoctorColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: DoctorColors.mainGradient),
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Analysis Detail 📊',
                            style: AppTextStyles.headingLarge(color: AppColors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Session Date: ${DateFormat('MMMM dd, yyyy').format(result.timestamp)}',
                          style: AppTextStyles.bodyMedium(color: AppColors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Overall Score Card ──────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _OverallScoreCard(result: result),
                ),
              ),

              // ── Analysis Card ────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: AnalysisCard(result: result),
                ),
              ),

              // ── Audio Section ───────────────────────────────
              if (audioUrl != null && audioUrl.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Audio Recording', style: AppTextStyles.headingSmall()),
                        const SizedBox(height: 12),
                        SessionAudioPlayer(audioUrl: audioUrl),
                      ],
                    ),
                  ),
                ),

              // ── Full Transcript Section ─────────────────────
              if (transcript.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Full Transcript', style: AppTextStyles.headingSmall()),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: DoctorColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: DoctorColors.divider),
                          ),
                          child: SelectableText(
                            transcript,
                            style: AppTextStyles.bodyMedium(color: DoctorColors.textPrimary).copyWith(height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Emotion Distribution ─────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: DoctorColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DoctorColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emotion Distribution', style: AppTextStyles.headingSmall()),
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            Text('Depression Confidence',
                                style: AppTextStyles.bodyMedium(color: DoctorColors.textSecondary)),
                            const SizedBox(height: 12),
                            EmotionPieChart(
                              positive: result.depression.isDepressed 
                                  ? 100 - result.depression.confidencePercent 
                                  : result.depression.confidencePercent,
                              negative: result.depression.isDepressed 
                                  ? result.depression.confidencePercent 
                                  : 100 - result.depression.confidencePercent,
                              positiveLabel: 'Non-Depressed',
                              negativeLabel: 'Depressed',
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),
                            Text('Sentiment Breakdown',
                                style: AppTextStyles.bodyMedium(color: DoctorColors.textSecondary)),
                            const SizedBox(height: 12),
                            EmotionPieChart(
                              positive: result.sentiment.isPositive
                                  ? result.sentiment.confidencePercent
                                  : 100 - result.sentiment.confidencePercent,
                              negative: result.sentiment.isPositive
                                  ? 100 - result.sentiment.confidencePercent
                                  : result.sentiment.confidencePercent,
                              positiveLabel: 'Positive',
                              negativeLabel: 'Negative',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Recommendations Card ───────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _RecommendationsCard(result: result),
                ),
              ),

              // ── Doctor Feedback Section ──────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinical Feedback', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 12),
                      TextField(
                        controller: feedbackController,
                        maxLines: 5,
                        readOnly: reviewed && !isEditing,
                        decoration: InputDecoration(
                          hintText: 'Enter clinical observations and advice...',
                          filled: true,
                          fillColor: (reviewed && !isEditing) ? DoctorColors.cardBg : DoctorColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: DoctorColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: DoctorColors.divider),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      if (reviewed && !isEditing)
                        OutlineButton(
                          label: 'Edit Feedback',
                          borderColor: DoctorColors.primary,
                          textColor: DoctorColors.primary,
                          onPressed: () => setState(() => isEditing = true),
                        )
                      else
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: feedbackController,
                          builder: (context, value, _) {
                            final bool hasText = value.text.trim().isNotEmpty;
                            return PrimaryButton(
                              label: reviewed ? 'Save Changes' : 'Mark Session Reviewed',
                              gradient: hasText ? DoctorColors.mainGradient : null,
                              solidColor: hasText ? null : DoctorColors.textHint,
                              onPressed: (hasText && (!reviewed || isEditing)) ? () async {
                                try {
                                  debugPrint("requiresEmergencyContact = $requiresEmergencyContact");
                                  debugPrint("riskLevel = ${result.riskLevel}");

                                  await DoctorService.reviewSession(
                                    widget.sessionId,
                                    doctorId,
                                    doctorName,
                                    feedbackController.text.trim(),
                                    requiresEmergencyContact,
                                  );

                                  String message = "Session marked as reviewed.";

                                  if (requiresEmergencyContact &&
                                      (result.riskLevel == "CRITICAL" || result.riskLevel == "HIGH")) {

                                    await DoctorService.confirmCritical(
                                      widget.sessionId,
                                    );

                                    message = "Session reviewed and emergency contacts notified.";
                                  }

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                    ),
                                  );

                                  setState(() {
                                    isEditing = false;
                                  });

                                  ref.invalidate(
                                    sessionDetailsProvider(widget.sessionId),
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              } : null,
                            );
                          },
                        ),

                      if (reviewed && !isEditing) ...[
                        const SizedBox(height: 12),
                        const PrimaryButton(
                          label: 'Already Reviewed',
                          onPressed: null,
                        ),
                      ],
                      // if (
                      // result.riskLevel == "CRITICAL"
                      // )
                      //   ...[
                      //     const SizedBox(
                      //       height: 20,
                      //     ),
                      //
                      //     Container(
                      //       padding:
                      //       const EdgeInsets.all(
                      //         16,
                      //       ),
                      //
                      //       decoration:
                      //       BoxDecoration(
                      //         color:
                      //         Colors.red.shade50,
                      //
                      //         borderRadius:
                      //         BorderRadius.circular(
                      //           16,
                      //         ),
                      //
                      //         border:
                      //         Border.all(
                      //           color:
                      //           Colors.red.shade200,
                      //         ),
                      //       ),
                      //
                      //       child: Row(
                      //         children: [
                      //
                      //           const Icon(
                      //             Icons.warning_amber_rounded,
                      //             color:
                      //             Colors.red,
                      //           ),
                      //
                      //           const SizedBox(
                      //             width: 12,
                      //           ),
                      //
                      //           Expanded(
                      //             child: Text(
                      //               reviewed
                      //                   ? "Critical case identified. Clinical review completed."
                      //                   : "Critical case detected. Immediate review recommended.",
                      //               style:
                      //               AppTextStyles.bodyMedium(),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      if (
                      result.riskLevel == "CRITICAL"||result.riskLevel == "HIGH"
                      )
                        ...[
                          const SizedBox(
                            height: 20,
                          ),

                          Container(
                            padding:
                            const EdgeInsets.all(
                              16,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              Colors.red.shade50,

                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),

                              border:
                              Border.all(
                                color:
                                Colors.red.shade200,
                              ),
                            ),

                            child: Column(
                              children: [

                                Row(
                                  children: [

                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color:
                                      Colors.red,
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Text(
                                        reviewed
                                            ? "Critical case identified. Clinical review completed."
                                            : "Critical case detected. Immediate review recommended.",

                                        style:
                                        AppTextStyles
                                            .bodyMedium(),
                                      ),
                                    ),
                                  ],
                                ),

                                if (
                                !reviewed
                                )
                                  CheckboxListTile(
                                    contentPadding:
                                    EdgeInsets.zero,

                                    activeColor:
                                    Colors.red,

                                    value:
                                    requiresEmergencyContact,

                                    onChanged:
                                        (value) {

                                      setState(
                                            () {

                                          requiresEmergencyContact =
                                              value ??
                                                  false;
                                        },
                                      );
                                    },

                                    title:
                                    const Text(
                                      "Notify emergency contacts",
                                    ),

                                    subtitle:
                                    const Text(
                                      "Enable only if clinical review confirms severe risk.",
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],

                      const SizedBox(height: 24),
                      
                      // ── Raw Technical Data ────────────────────────────
                      ExpansionTile(
                        title: Text('Technical Analysis Data', 
                          style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: DoctorColors.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: DoctorColors.divider),
                            ),
                            child: Builder(
                              builder: (context) {
                                final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
                                return SelectableText(
                                  jsonStr,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
    Color scoreColor = score >= 65 ? DoctorColors.success : (score >= 40 ? DoctorColors.warning : DoctorColors.error);
    String scoreLabel = score >= 65 ? 'Stable' : (score >= 40 ? 'Moderate' : 'High Indicators');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DoctorColors.divider),
        boxShadow: [
          BoxShadow(color: scoreColor.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: DoctorColors.divider,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(score.toStringAsFixed(0), style: AppTextStyles.headingLarge(color: scoreColor)),
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
                Text('Wellness Score', style: AppTextStyles.labelSmall()),
                const SizedBox(height: 4),
                Text(scoreLabel, style: AppTextStyles.headingMedium(color: DoctorColors.textPrimary)),
                const SizedBox(height: 8),
                StatusBadge(
                  label: result.sentiment.isPositive ? '😊 Positive Sentiment' : '😔 Negative Sentiment',
                  color: result.sentiment.isPositive ? DoctorColors.success : DoctorColors.error,
                ),
                const SizedBox(height: 8),

                StatusBadge(
                  label:
                  "Risk: ${result.riskLevel}",

                  color:
                  result.riskLevel == "CRITICAL"
                      ? Colors.red
                      : result.riskLevel == "HIGH"
                      ? Colors.orange
                      : result.riskLevel == "MODERATE"
                      ? Colors.amber
                      : Colors.green,
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
        _Tip('💬', 'Patient may require clinical intervention soon.'),
        _Tip('🌿', 'Recommend increased frequency of check-ins.'),
      ];
    }
    return const [
      _Tip('🎉', 'Patient appears stable based on current data.'),
      _Tip('😴', 'Reinforce healthy sleep and routine habits.'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical Recommendations', style: AppTextStyles.headingSmall()),
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
                    style: AppTextStyles.bodyMedium(color: DoctorColors.textSecondary),
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
  final String emoji, text;
  const _Tip(this.emoji, this.text);
}

class SessionAudioPlayer extends StatefulWidget {
  final String audioUrl;
  const SessionAudioPlayer({super.key, required this.audioUrl});
  @override
  State<SessionAudioPlayer> createState() => _SessionAudioPlayerState();
}

class _SessionAudioPlayerState extends State<SessionAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) { if (mounted) setState(() => duration = d); });
    _audioPlayer.onPositionChanged.listen((p) { if (mounted) setState(() => position = p); });
    _audioPlayer.onPlayerComplete.listen((_) { if (mounted) setState(() { isPlaying = false; position = Duration.zero; }); });
  }

  @override
  void dispose() { _audioPlayer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on context (doctor vs patient)
    final bool isDoctor = context.findAncestorWidgetOfExactType<DoctorSessionDetailsScreen>() != null;
    final primaryColor = isDoctor ? DoctorColors.primary : PatientColors.primary;
    final surfaceColor = isDoctor ? DoctorColors.primarySurface : PatientColors.primarySurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, size: 44, color: primaryColor),
            onPressed: () async {
              if (isPlaying) await _audioPlayer.pause();
              else await _audioPlayer.play(widget.audioUrl.startsWith('http') ? UrlSource(widget.audioUrl) : DeviceFileSource(widget.audioUrl));
              if (mounted) setState(() => isPlaying = !isPlaying);
            },
          ),
          Expanded(
            child: Column(
              children: [
                Slider(
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
                  activeColor: primaryColor,
                  onChanged: (val) async => await _audioPlayer.seek(Duration(seconds: val.toInt())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 12)),
                      Text("${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
