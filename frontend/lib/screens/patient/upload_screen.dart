// lib/screens/patient/upload_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/analysis_provider.dart';
import '../../router/app_router.dart';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart';

enum AnalysisType { fusion, text }

class UploadScreen extends ConsumerStatefulWidget {
  final AnalysisType type;

  const UploadScreen({super.key, required this.type});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _diaryCtrl = TextEditingController();
  bool _isPickingFile = false;
  bool _isRecording = false;
  String? _recordedAudioPath;

  @override
  void dispose() {
    _diaryCtrl.dispose();
    super.dispose();
  }

  // ── Pick audio file using file_picker ────────────────────────────────────
  Future<void> _pickAudioFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a', 'ogg', 'flac'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        final pickedFile = result.files.single;

        ref.read(analysisProvider.notifier).setAudioFile(pickedFile);

        if (kIsWeb) {
          // WEB
          final bytes = pickedFile.bytes;

          if (result != null) {
            final pickedFile = result.files.single;

            ref.read(analysisProvider.notifier).setAudioFile(pickedFile);
          }
        } else {
          // MOBILE / DESKTOP
          if (pickedFile.path != null) {
            final pickedFile = result.files.single;

            ref.read(analysisProvider.notifier).setAudioFile(pickedFile);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick file: $e'),
            backgroundColor: PatientColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  // ── Start analysis: navigate to processing screen ────────────────────────
  // void _startAnalysis() {
  //   context.go(AppRoutes.aiProcessing);
  // }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);
    final notifier = ref.read(analysisProvider.notifier);

    return Scaffold(
      backgroundColor: PatientColors.background,
      appBar: AppBar(
        // title: const Text('Upload for Analysis'),
        title: const Text('Submit Analysis',),
        backgroundColor: PatientColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          // onPressed: () => context.go(AppRoutes.patientDashboard),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ─────────────────────────
            _buildInfoBanner(),
            const SizedBox(height: 24),

            // ======================================================
            // FUSION MODE
            // ======================================================
            if (widget.type == AnalysisType.fusion) ...[
              Text(
                'Step 1',
                style: AppTextStyles.labelSmall(color: PatientColors.primary),
              ),

              const SizedBox(height: 8),

              Text(
                'Upload Audio Recording',
                style: AppTextStyles.headingMedium(),
              ),

              const SizedBox(height: 4),

              Text(
                'Speak naturally for 30–60 seconds',
                style: AppTextStyles.bodySmall(),
              ),

              const SizedBox(height: 12),

              _buildAudioSourceSelector(analysisState, notifier),

              const SizedBox(height: 32),
            ],

            // ======================================================
            // TEXT MODE
            // ======================================================
            if (widget.type == AnalysisType.text) ...[
              Text(
                'Step 1',
                style: AppTextStyles.labelSmall(color: PatientColors.accent),
              ),

              const SizedBox(height: 8),

              Text('Upload Diary Entry', style: AppTextStyles.headingMedium()),

              const SizedBox(height: 4),

              Text(
                'Write your thoughts or diary notes',
                style: AppTextStyles.bodySmall(),
              ),

              const SizedBox(height: 12),

              _buildDiaryEntryCard(analysisState, notifier),

              const SizedBox(height: 32),
            ],

            // ── Analyse Button ──────────────────────
            PrimaryButton(
              label: widget.type == AnalysisType.fusion
                  ? '📤 Submit Audio Analysis'
                  : '📤 Submit Diary Entry',
              gradient: analysisState.canAnalyse
                  ? PatientColors.mainGradient
                  : null,
              solidColor: analysisState.canAnalyse
                  ? null
                  : PatientColors.textHint,
              height: 58,
            onPressed: analysisState.canAnalyse
    ? () {
        if (widget.type == AnalysisType.fusion) {
          context.push(
            '${AppRoutes.aiProcessing}?mode=fusion',
          );
        } else {
          context.push(
            '${AppRoutes.aiProcessing}?mode=directText',
          );
        }
      }
    : null,
    //           onPressed: analysisState.canAnalyse
    //               ? () {
    //
    //             final type =
    //             widget.type == AnalysisType.text
    //                 ? "text"
    //                 : "fusion";
    //
    //             context.push(
    //               '${AppRoutes.analysisDisclaimer}?type=$type',
    //             );
    //
    //           }
    //               : null,
            ),
            const SizedBox(height: 12),
            if (!analysisState.canAnalyse)
              Center(
                child: Text(
                  widget.type == AnalysisType.fusion
                      ? 'Upload audio to continue'
                      : 'Write diary entry to continue',
                  style: AppTextStyles.bodySmall(),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PatientColors.accentSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatientColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              // 'Uploading both audio AND transcript gives the most accurate emotional analysis.',
              'Your uploaded information will be reviewed by your connected healthcare professionals before feedback is provided.',
              style: AppTextStyles.bodySmall(
                color: PatientColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioUploadCard(AnalysisState state, AnalysisNotifier notifier) {
    final hasAudio = state.hasAudio;

    return GestureDetector(
      // onTap: () {
      //   // Simulate file picker — replace with file_picker package call
      //
      //   notifier.setAudioFile('my_recording_${DateTime.now().millisecond}.mp3');
      // },
      // onTap: _isPickingFile ? null : _pickAudioFile,
    onTap: hasAudio
    ? null
        : (_isPickingFile
    ? null
    : _pickAudioFile),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: hasAudio
              ? PatientColors.primarySurface
              : PatientColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasAudio ? PatientColors.primary : PatientColors.divider,
            width: hasAudio ? 2 : 1,
          ),
          boxShadow: hasAudio
              ? [
                  BoxShadow(
                    color: PatientColors.primary.withOpacity(0.1),
                    blurRadius: 16,
                  ),
                ]
              : [],
        ),
        child: hasAudio
            ? Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: PatientColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.audiotrack_rounded,
                      color: PatientColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.audioFileName!,
                          style: AppTextStyles.bodyMedium(
                            color: PatientColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // 'Audio ready for analysis',
                          'Uploaded successfully',
                          style: AppTextStyles.bodySmall(
                            color: PatientColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: PatientColors.error,
                    ),
                    onPressed: () => notifier.clearAudio(),
                  ),
                ],
              )
            : Column(
                children: [
                  // ── CHANGED: spinner while picker is open ──────────────
                  _isPickingFile
                      ? const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(
                              PatientColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: PatientColors.mainGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                  const SizedBox(height: 14),
                  Text(
                    'Tap to upload audio',
                    style: AppTextStyles.bodyMedium(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MP3, WAV, M4A supported',
                    style: AppTextStyles.bodySmall(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: PatientColors.primary.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Choose File',
                      style: AppTextStyles.labelMedium(
                        color: PatientColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDiaryEntryCard(AnalysisState state, AnalysisNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: PatientColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PatientColors.divider),
      ),
      child: Column(
        children: [
          TextField(
            controller: _diaryCtrl,
            maxLines: 6,
            onChanged: notifier.setTranscript,
            style: AppTextStyles.bodyMedium(color: PatientColors.textPrimary),
            decoration: InputDecoration(
              hintText:
                  'Write how your day went, your thoughts, emotions, or experiences...\n\nExample: "I felt overwhelmed today and struggled to focus..."',
              hintStyle: AppTextStyles.bodySmall(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          if (state.hasTranscript)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: PatientColors.accentSurface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: PatientColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Transcript ready',
                    style: AppTextStyles.bodySmall(color: PatientColors.accent),
                  ),
                  const Spacer(),
                  Text(
                    '${_diaryCtrl.text.split(' ').length} words',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioSourceSelector(
    AnalysisState state,
    AnalysisNotifier notifier,
  ) {
    if (state.hasAudio) {
      return _buildAudioUploadCard(
        state,
        notifier,
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PatientColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PatientColors.divider),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Audio'),
              onPressed: _pickAudioFile,
            ),
          ),

          const SizedBox(height: 16),

          Text('OR', style: AppTextStyles.bodyMedium()),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: const Text('Record Audio'),
              onPressed: () {
                context.push(AppRoutes.liveRecord);
              },
            ),
          ),
        ],
      ),
    );
  }
}
