// // lib/screens/patient/ai_processing_screen.dart
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// import '../../providers/analysis_provider.dart';
// import '../../router/app_router.dart';
// import '../../widgets/patient/waveform_widget.dart';
//
// class AiProcessingScreen extends ConsumerStatefulWidget {
//   const AiProcessingScreen({super.key});
//
//   @override
//   ConsumerState<AiProcessingScreen> createState() => _AiProcessingScreenState();
// }
//
// class _AiProcessingScreenState extends ConsumerState<AiProcessingScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnim;
//
//   // final List<String> _steps = [
//   //   'Uploading your data securely...',
//   //   'Analysing audio patterns...',
//   //   'Processing transcript sentiment...',
//   //   'Running depression detection model...',
//   //   'Finalising your wellness report...',
//   // ];
//   // Step labels shown while the server processes the audio
//   final List<String> _steps = [
//     'Uploading audio securely...',
//     'Cleaning & preprocessing audio...',
//     'Transcribing speech to text...',
//     'Extracting audio embeddings...',
//     'Running Fusion model...',
//     'Finalising your wellness report...',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//
//     _rotateController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat();
//
//     _pulseAnim = Tween<double>(begin: 0.9, end: 1.08).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     // Start the analysis
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _startAnalysis();
//     });
//   }
//
//   // Future<void> _startAnalysis() async {
//   //   await ref.read(analysisProvider.notifier).runAnalysis();
//   //   if (mounted) {
//   //     context.go(AppRoutes.results);
//   //   }
//   // }
//   Future<void> _startAnalysis() async {
//     await ref.read(analysisProvider.notifier).runAnalysis();
//     if (!mounted) return;
//
//     final state = ref.read(analysisProvider);
//
//     if (state.status == AnalysisStatus.completed) {
//       context.go(AppRoutes.results);
//     } else if (state.status == AnalysisStatus.error) {
//       // Stay on this screen and show error overlay (handled in build)
//     }
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(analysisProvider);
//     final progress = state.processingProgress;
//     final stepIndex = (progress * _steps.length).clamp(0, _steps.length - 1).toInt();
//     // ── Error state ────────────────────────────────────────────────────────
//     if (state.status == AnalysisStatus.error) {
//       return Scaffold(
//         body: Container(
//           decoration:
//           const BoxDecoration(gradient: PatientColors.splashGradient),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Column(
//                 children: [
//                   const Spacer(flex: 2),
//                   const Text('⚠️', style: TextStyle(fontSize: 64)),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Analysis Failed',
//                     style:
//                     AppTextStyles.displayMedium(color: AppColors.white),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: AppColors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       state.errorMessage ?? 'Unknown error',
//                       style: AppTextStyles.bodySmall(
//                           color: AppColors.white.withOpacity(0.9)),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Make sure your FastAPI server is running and reachable.',
//                     style: AppTextStyles.bodySmall(
//                         color: AppColors.white.withOpacity(0.7)),
//                     textAlign: TextAlign.center,
//                   ),
//                   const Spacer(flex: 2),
//                   // ── Retry button ───────────────────────────────
//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.refresh_rounded),
//                       label: const Text('Retry'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.white,
//                         foregroundColor: PatientColors.primary,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                       ),
//                       onPressed: () {
//                         ref.read(analysisProvider.notifier).reset();
//                         context.go(AppRoutes.patientUpload);
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextButton(
//                     onPressed: () =>
//                         context.go(AppRoutes.patientDashboard),
//                     child: Text(
//                       'Back to Dashboard',
//                       style: AppTextStyles.bodySmall(
//                           color: AppColors.white.withOpacity(0.8)),
//                     ),
//                   ),
//                   const Spacer(flex: 1),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//     // ── Processing state ───────────────────────────────────────────────────
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(gradient: PatientColors.splashGradient),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Column(
//               children: [
//                 const Spacer(flex: 2),
//
//                 // ── Animated brain icon ──────────────────
//                 ScaleTransition(
//                   scale: _pulseAnim,
//                   child: Container(
//                     width: 110,
//                     height: 110,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: AppColors.white.withOpacity(0.15),
//                       border: Border.all(
//                           color: AppColors.white.withOpacity(0.35), width: 2),
//                     ),
//                     child: const Center(
//                       child: Text('🧠', style: TextStyle(fontSize: 52)),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // ── Heading ───────────────────────────────
//                 Text(
//                   'Analysing Your\nEmotional State',
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.displayMedium(color: AppColors.white),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Our AI is working to understand\nyour mental wellness patterns.',
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.tagline(),
//                 ),
//
//                 const Spacer(flex: 2),
//
//                 // ── Waveform ───────────────────────────────
//                 WaveformWidget(
//                   isPlaying: true,
//                   color: AppColors.white.withOpacity(0.7),
//                   height: 60,
//                 ),
//
//                 const Spacer(flex: 1),
//
//                 // ── Progress bar ────────────────────────────
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     minHeight: 8,
//                     backgroundColor: AppColors.white.withOpacity(0.2),
//                     valueColor: const AlwaysStoppedAnimation(AppColors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // ── Current step label ────────────────────────
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 400),
//                   child: Text(
//                     _steps[stepIndex],
//                     key: ValueKey(stepIndex),
//                     textAlign: TextAlign.center,
//                     style: AppTextStyles.bodyMedium(color: AppColors.white.withOpacity(0.9)),
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 Text(
//                   '${(progress * 100).toStringAsFixed(0)}%',
//                   style: AppTextStyles.headingSmall(color: AppColors.white),
//                 ),
//
//                 const Spacer(flex: 2),
//
//                 // ── Privacy note ──────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: AppColors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.white.withOpacity(0.2)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text('🔒', style: TextStyle(fontSize: 16)),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Your data is encrypted end-to-end',
//                         style: AppTextStyles.bodySmall(color: AppColors.white.withOpacity(0.85)),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const Spacer(flex: 1),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/patient/ai_processing_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/analysis_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/patient/waveform_widget.dart';

class AiProcessingScreen extends ConsumerStatefulWidget {
  final String mode;

  const AiProcessingScreen({
    super.key,
    required this.mode,
  });

  @override
  ConsumerState<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends ConsumerState<AiProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;
  ProviderSubscription? _analysisSub;

  final List<String> _steps = [
    'Uploading securely...',
    'Preparing submission...',
    'Running AI analysis...',
    'Saving analysis session...',
    'Sharing with connected doctors...',
    'Finalising...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _analysisSub = ref.listenManual<AnalysisState>(
      analysisProvider,
      (previous, next) {
        if (!mounted) return;

        // SUCCESS
        if (next.status == AnalysisStatus.completed && previous?.status != AnalysisStatus.completed) {
          context.go(AppRoutes.analysisSuccess);
        }

        // ERROR
        if (next.status == AnalysisStatus.error && previous?.status != AnalysisStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Analysis failed'),
            ),
          );
        }
      },
    );

    // Start the analysis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    final notifier = ref.read(analysisProvider.notifier);
    if (widget.mode == "text" || widget.mode == "directText") {
      await notifier.runTypedTextAnalysis();
    } else {
      await notifier.runAnalysis();
    }
  }

  @override
  void dispose() {
    _analysisSub?.close();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);
    final progress = state.processingProgress;
    final stepIndex = (progress * _steps.length).clamp(0, _steps.length - 1).toInt();

    // ── Error state ────────────────────────────────────────────────────────
    if (state.status == AnalysisStatus.error) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: PatientColors.splashGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const Text('⚠️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 24),
                  Text(
                    'Analysis Failed',
                    style: AppTextStyles.displayMedium(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.errorMessage ?? 'Unknown error',
                      style: AppTextStyles.bodySmall(
                          color: AppColors.white.withOpacity(0.9)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure your FastAPI server is running and reachable.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.white.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  // ── Retry button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: PatientColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ref.read(analysisProvider.notifier).reset();
                        context.go(
                          '${AppRoutes.patientUpload}?type=${widget.mode == "text" ? "text" : "fusion"}',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.patientDashboard),
                    child: Text(
                      'Back to Dashboard',
                      style: AppTextStyles.bodySmall(
                          color: AppColors.white.withOpacity(0.8)),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Processing state ───────────────────────────────────────────────────
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PatientColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated brain icon ──────────────────
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.15),
                      border: Border.all(
                          color: AppColors.white.withOpacity(0.35), width: 2),
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Heading ───────────────────────────────
                Text(
                  'Preparing Your Report',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium(color: AppColors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your submission is being securely\n processed for professional review.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tagline(),
                ),

                const Spacer(flex: 2),

                // ── Waveform ───────────────────────────────
                WaveformWidget(
                  isPlaying: true,
                  color: AppColors.white.withOpacity(0.7),
                  height: 60,
                ),

                const Spacer(flex: 1),

                // ── Progress bar ────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Current step label ────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _steps[stepIndex],
                    key: ValueKey(stepIndex),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(color: AppColors.white.withOpacity(0.9)),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.headingSmall(color: AppColors.white),
                ),

                const Spacer(flex: 2),

                // ── Privacy note ──────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Your data is encrypted end-to-end',
                        style: AppTextStyles.bodySmall(color: AppColors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
