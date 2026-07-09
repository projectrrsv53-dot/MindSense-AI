// lib/screens/patient/patient_session_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../providers/doctor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/analysis_result.dart';
import '../../widgets/common/status_badge.dart';

class PatientSessionDetailsScreen extends ConsumerWidget {
  final String sessionId;

  const PatientSessionDetailsScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailsProvider(sessionId));

    return Scaffold(
      backgroundColor: PatientColors.background,
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Scaffold(
          appBar: AppBar(backgroundColor: PatientColors.background, elevation: 0),
          body: Center(child: Text(e.toString())),
        ),
        data: (data) {
          final bool reviewed = data['doctor_reviewed'] ?? false;
          final String doctorFeedback = data['doctor_feedback'] ?? '';
          final String analysisType = data["analysis_type"] ?? "text";
          // final String transcript = data['transcript'] ?? '';
          final String transcript = analysisType == "text"
              ? (data["original_text"] ?? "")
              : (data["transcript"] ?? "");
          final String? audioUrl = data['audio_url'];

          
          final dynamic reviewedAtRaw = data['reviewed_at'] ?? data['updated_at'];
          final String reviewedDateStr = reviewedAtRaw != null 
              ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(reviewedAtRaw.toString()))
              : 'N/A';

          final result = AnalysisResult.fromBackend(data);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: PatientColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: PatientColors.mainGradient),
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${analysisType.toUpperCase()} SESSION",
                          style: AppTextStyles.headingLarge(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(result.timestamp),
                          style: AppTextStyles.bodyMedium(color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Review Status Banner ───────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: reviewed ? PatientColors.success.withValues(alpha: 0.1) : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: reviewed ? PatientColors.success.withValues(alpha: 0.3) : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reviewed ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                          color: reviewed ? PatientColors.success : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reviewed ? 'Session Reviewed' : 'Review Pending',
                                style: AppTextStyles.headingSmall(
                                  color: reviewed ? PatientColors.success : Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reviewed 
                                  ? 'This session was professionally reviewed on $reviewedDateStr'
                                  : 'Our clinical team is currently reviewing your submission.',
                                style: AppTextStyles.bodySmall(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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

              if (transcript.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Full Transcript', style: AppTextStyles.headingSmall()),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: PatientColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: PatientColors.divider),
                            ),
                            child: SelectableText(
                              transcript,
                              style: AppTextStyles.bodyMedium(color: PatientColors.textPrimary).copyWith(height: 1.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _RecommendationsCard(result: result),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinical Feedback', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 12),
                      if (reviewed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: PatientColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: PatientColors.divider),
                          ),
                          child: SelectableText(
                            doctorFeedback,
                            style: AppTextStyles.bodyMedium(color: PatientColors.textPrimary).copyWith(height: 1.6),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            "Feedback will appear here once your healthcare provider reviews this session.",
                            style: AppTextStyles.bodySmall(color: PatientColors.textSecondary),
                          ),
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

class _RecommendationsCard extends StatelessWidget {
  final AnalysisResult result;
  const _RecommendationsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final tips = result.depression.isDepressed 
      ? const [_Tip('💬', 'Consider reaching out for support.'), _Tip('🌿', 'Try some breathing exercises.')]
      : const [_Tip('🎉', 'Great job maintaining your wellness!'), _Tip('😴', 'Keep up your healthy routine.')];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: PatientColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: PatientColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wellness Recommendations', style: AppTextStyles.headingSmall()),
          const SizedBox(height: 14),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [Text(tip.emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12), Expanded(child: Text(tip.text, style: AppTextStyles.bodyMedium(color: PatientColors.textSecondary)))]),
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
    final primaryColor = PatientColors.primary;
    final surfaceColor = PatientColors.primarySurface;

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
