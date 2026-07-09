// providers/analysis_provider.dart
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_history_model.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../models/mood_point.dart';
import '/services/api_service.dart';
import 'auth_provider.dart';

enum AnalysisStatus {
  idle,
  uploading,
  processing,
  completed,
  error,
}

class AnalysisState {
  final PlatformFile? audioFile;
  final AnalysisStatus status;
  final String? audioFileName;
  final String? transcriptText;
  final AnalysisResult? result;
  final String? errorMessage;
  final double processingProgress;

  const AnalysisState({
    this.audioFile,
    this.status = AnalysisStatus.idle,
    this.audioFileName,
    this.transcriptText,
    this.result,
    this.errorMessage,
    this.processingProgress = 0.0,
  });

  AnalysisState copyWith({
    PlatformFile? audioFile,
    AnalysisStatus? status,
    String? audioFileName,
    String? transcriptText,
    AnalysisResult? result,
    String? errorMessage,
    double? processingProgress,
  }) {
    return AnalysisState(
      audioFile: audioFile ?? this.audioFile,
      status: status ?? this.status,
      audioFileName: audioFileName ?? this.audioFileName,
      transcriptText: transcriptText ?? this.transcriptText,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      processingProgress:
      processingProgress ?? this.processingProgress,
    );
  }

  bool get hasAudio => audioFile != null;

  bool get hasTranscript =>
      transcriptText != null &&
          transcriptText!.trim().isNotEmpty;

  bool get canAnalyse => hasAudio || hasTranscript;
}

class AnalysisNotifier
    extends StateNotifier<AnalysisState> {

  final ApiService _api = ApiService();
  final String patientId;

  AnalysisNotifier(this.patientId)
      : super(const AnalysisState());

  void setAudioFile(PlatformFile file) {
    state = state.copyWith(
      audioFile: file,
      audioFileName: file.name,
    );
  }

  void setTranscript(String text) {
    state = state.copyWith(
      transcriptText: text,
    );
  }

  void clearAudio() {
    state = AnalysisState(
      transcriptText: state.transcriptText,
    );
  }

  void clearTranscript() {
    state = AnalysisState(
      audioFile: state.audioFile,
      audioFileName: state.audioFileName,
    );
  }

  Future<void> runAnalysis() async {
    if (state.status == AnalysisStatus.uploading || state.status == AnalysisStatus.processing) return;

    debugPrint("===== runAnalysis called =====");
    debugPrint(state.audioFile.toString());
    debugPrint(state.audioFile?.path);
    debugPrint(state.audioFile?.name);
    if (!state.canAnalyse) return;

    try {
      state = state.copyWith(
        status: AnalysisStatus.uploading,
        processingProgress: 0.05,
        errorMessage: null,
      );

      final pickedFile = state.audioFile!;

      final progressFuture = _advanceProgress();

      FusionApiResponse apiResponse;

      if (pickedFile.bytes != null) {
        apiResponse = await predictFusionBytes(
          pickedFile.bytes!,
          patientId,
          pickedFile.name,
        );
      }
      else if (pickedFile.path != null) {
        apiResponse = await predictFusionFile(
          patientId,
          pickedFile.path!,
        );
      } else {
        throw Exception(
          'Invalid audio file selected',
        );
      }

      await progressFuture;

      final result = AnalysisResult.fromFusionApi(
        apiResponse: apiResponse,
        audioFileName: pickedFile.name,
      );
      // await _api.saveAnalysis(
      //   patientId: patientId,
      //   result: result,
      //   type: 'fusion',
      // );

      state = state.copyWith(
        status: AnalysisStatus.completed,
        result: result,
        processingProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: e.toString(),
        processingProgress: 0.0,
      );
    }
  }

  Future<void> runTextAnalysis() async {
    if (!state.hasTranscript || state.status == AnalysisStatus.uploading || state.status == AnalysisStatus.processing) return;

    try {
      state = state.copyWith(
        status: AnalysisStatus.uploading,
        processingProgress: 0.05,
        errorMessage: null,
      );

      final progressFuture = _advanceProgress();

      final response = await predictText(
        patientId,
        state.transcriptText!,
      );

      await progressFuture;

      final result = AnalysisResult.fromTextApi(
        response,
      );
      // await _api.saveAnalysis(
      //   patientId: patientId,
      //   result: result,
      //   type: 'text',
      // );

      state = state.copyWith(
        status: AnalysisStatus.completed,
        result: result,
        processingProgress: 1.0,
      );

    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: e.toString(),
        processingProgress: 0.0,
      );
    }
  }

  Future<void> _advanceProgress() async {
    final steps = [
      (0.15, 600),
      (0.30, 800),
      (0.50, 1000),
      (0.65, 800),
      (0.80, 600),
      (0.92, 500),
    ];

    for (final (target, ms) in steps) {
      await Future.delayed(
        Duration(milliseconds: ms),
      );

      if (state.status ==
          AnalysisStatus.error) {
        return;
      }

      state = state.copyWith(
        status: AnalysisStatus.processing,
        processingProgress: target,
      );
    }
  }

  void reset() {
    state = const AnalysisState();
  }

  Future<void> runTypedTextAnalysis() async {
  if (!state.hasTranscript || state.status == AnalysisStatus.uploading || state.status == AnalysisStatus.processing) return;

  try {
    state = state.copyWith(
      status: AnalysisStatus.uploading,
      processingProgress: 0.05,
      errorMessage: null,
    );

    final progressFuture = _advanceProgress();

    // Calls the NEW API (/predict-text-direct)
    final response = await predictDirectText(
      patientId,
      state.transcriptText!,
    );

    await progressFuture;

    final result = AnalysisResult.fromTextApi(response);

    // await _api.saveAnalysis(
    //   patientId: patientId,
    //   result: result,
    //   type: 'text',
    // );

    state = state.copyWith(
      status: AnalysisStatus.completed,
      result: result,
      processingProgress: 1.0,
    );

  } catch (e) {
    state = state.copyWith(
      status: AnalysisStatus.error,
      errorMessage: e.toString(),
      processingProgress: 0.0,
    );
  }
}
}

final analysisProvider =
StateNotifierProvider<
    AnalysisNotifier,
    AnalysisState>((ref) {

  // final auth = ref.watch(authProvider);
  final auth = ref.read(authProvider);

  return AnalysisNotifier(
    auth.userId ?? " ",
  );
});

final sessionHistoryProvider =
FutureProvider<List<AnalysisResult>>((ref) async {
  final auth = ref.read(authProvider);

  return await ApiService().getPatientSessions( auth.userId!,);

});

final moodTrendProvider =
FutureProvider<List<MoodPoint>>((
    ref,
    ) async {
  final data = await fetchTrendData();
  return data.map<MoodPoint>((e) {
    return MoodPoint.fromJson(e);
  }).toList();
});

final historyProvider =
FutureProvider<List<AnalysisHistoryModel>>(
      (ref) async {

    final auth = ref.read(authProvider);

    return await fetchPatientHistory(
      auth.userId!,
    );
  },
);
