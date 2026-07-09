// models/analysis_result.dart
import '../services/api_service.dart';

class AnalysisResult {
  final String sessionId;
  final DateTime timestamp;
  final DepressionResult depression;
  final SentimentResult sentiment;
  final double overallEmotionalScore;
  final String audioFileName;
  final String transcriptPreview;
  final String? doctorNotes;
  final String? doctorFeedback;
  final String riskLevel;
  final bool doctorReviewed;
  final bool requiresEmergencyContact;
  final bool emergencyNotified;
  final DateTime? emergencyNotifiedAt;
  final String recommendation;

  const AnalysisResult({
    required this.sessionId,
    required this.timestamp,
    required this.depression,
    required this.sentiment,
    required this.overallEmotionalScore,
    required this.audioFileName,
    required this.transcriptPreview,
    required this.riskLevel,
    required this.doctorReviewed,
    required this.requiresEmergencyContact,
    required this.emergencyNotified,
    required this.recommendation,
    this.emergencyNotifiedAt,
    this.doctorNotes,
    this.doctorFeedback,
  });

  factory AnalysisResult.fromFusionApi({
    required FusionApiResponse apiResponse,
    required String audioFileName,
  }) {
    final pred = apiResponse.fusionPrediction;
    final String recommendation = apiResponse.recommendation;
    
    final depression = DepressionResult(
      label: pred.isDepressed ? 'depressed' : 'not depressed',
      confidence: pred.confidence,
    );
    final sentiment = SentimentResult(
      label: apiResponse.sentimentLabel,
      confidence: apiResponse.sentimentConfidence,
    );

    final double emotionalScore = pred.isDepressed ? (1.0 - pred.confidence) * 100 : pred.confidence * 100;

    return AnalysisResult(
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      depression: depression,
      sentiment: sentiment,
      overallEmotionalScore: emotionalScore.clamp(0.0, 100.0),
      audioFileName: audioFileName,
      transcriptPreview: apiResponse.transcript.length > 120
          ? '${apiResponse.transcript.substring(0, 120)}...'
          : apiResponse.transcript,
      riskLevel: "LOW",
      doctorReviewed: false,
      requiresEmergencyContact: false,
      emergencyNotified: false,
      emergencyNotifiedAt: null,
      doctorFeedback: null,
      recommendation: recommendation,
    );
  }

  factory AnalysisResult.fromTextApi(Map<String, dynamic> json) {
    final sentimentJson = json['sentiment'] as Map<String, dynamic>? ?? {};
    final depressionJson = json['depression'] as Map<String, dynamic>? ?? {};

    final String label = (depressionJson['label'] ?? 'unknown').toString().trim().toLowerCase();
    final bool isDepressed = label == 'depressed';
    final double confidence = (depressionJson['confidence'] as num?)?.toDouble() ?? 0.0;
    final double emotionalScore = isDepressed ? (1.0 - confidence) * 100 : confidence * 100;

    final depression = DepressionResult(
      label: label,
      confidence: confidence,
    );
    final sentiment = SentimentResult(
      label: sentimentJson['label']?.toString() ?? 'neutral',
      confidence: (sentimentJson['confidence'] as num?)?.toDouble() ?? 0.0,
    );

    return AnalysisResult(
      sessionId: 'text_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      depression: depression,
      sentiment: sentiment,
      overallEmotionalScore: emotionalScore.clamp(0.0, 100.0),
      audioFileName: 'Diary Entry',
      transcriptPreview: json['original_text']?.toString() ?? '',
      riskLevel: json["risk_level"] ?? "LOW",
      doctorReviewed: json["doctor_reviewed"] ?? false,
      requiresEmergencyContact: json["requires_emergency_contact"] ?? false,
      emergencyNotified: json["emergency_notified"] ?? false,
      emergencyNotifiedAt: json["emergency_notified_at"] != null
          ? DateTime.parse(json["emergency_notified_at"])
          : null,
      doctorFeedback: json["doctor_feedback"],
      recommendation: json["recommendation"] ?? "",
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final String label = (json['depression_label'] ?? 'not depressed').toString().trim().toLowerCase();
    final double confidence = (json['depression_confidence'] as num? ?? 0.0).toDouble();
    final bool isDepressed = label == 'depressed';
    
    double score = (json['overall_score'] as num? ?? 0.0).toDouble();
    if (score == 0 && confidence > 0) {
       score = isDepressed ? (1 - confidence) * 100 : confidence * 100;
    }

    return AnalysisResult(
      sessionId: json['session_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      depression: DepressionResult(
        label: label,
        confidence: confidence,
      ),
      sentiment: SentimentResult(
        label: json['sentiment_label'] ?? 'positive',
        confidence: (json['sentiment_confidence'] as num? ?? 0.0).toDouble(),
      ),
      overallEmotionalScore: score.clamp(0.0, 100.0),
      audioFileName: json['audio_file'] ?? 'N/A',
      transcriptPreview: json["transcript"] ?? json["original_text"] ?? "",
      riskLevel: json["risk_level"] ?? "LOW",
      doctorReviewed: json["doctor_reviewed"] ?? false,
      requiresEmergencyContact: json["requires_emergency_contact"] ?? false,
      emergencyNotified: json["emergency_notified"] ?? false,
      emergencyNotifiedAt: json["emergency_notified_at"] != null
          ? DateTime.parse(json["emergency_notified_at"])
          : null,
      doctorFeedback: json["doctor_feedback"],
      recommendation: json["recommendation"] ?? "",
    );
  }

  factory AnalysisResult.fromBackend(Map<String, dynamic> json) {
    final depressionJson = json['fusion_prediction'] ?? json['depression'] ?? json['prediction'] ?? {};
    final sentimentJson = json['sentiment'] ?? {};
    print("===== RAW JSON =====");
    print(json);

    double confidence = (depressionJson['confidence'] as num?)?.toDouble() ?? 
                       (json['overall_score'] as num?)?.toDouble() ?? 0.0;
    
    if (confidence > 1.0) confidence /= 100.0;

    final String label = (depressionJson['prediction'] ?? 
                         depressionJson['label'] ?? 
                         json['prediction'] ?? 
                         'non-depressed').toString().trim().toLowerCase();

    final bool isDepressed = label == 'depressed';
    final double emotionalScore = isDepressed ? (1 - confidence) * 100 : confidence * 100;

    return AnalysisResult(
      sessionId: json['session_id'] ?? '',
      timestamp: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      depression: DepressionResult(
        label: label,
        confidence: confidence,
      ),
      sentiment: SentimentResult(
        label: sentimentJson['label'] ?? 'neutral',
        confidence: (sentimentJson['confidence'] as num? ?? 0.0).toDouble(),
      ),
      overallEmotionalScore: emotionalScore.clamp(0.0, 100.0),
      audioFileName: json["analysis_type"] == "audio"
          ? "Audio Recording"
          : json["analysis_type"] == "fusion"
          ? "Fusion Analysis"
          : "Diary Entry",
      transcriptPreview: json["transcript"] ?? json["original_text"] ?? "",
      riskLevel: json["risk_level"] ?? "LOW",
      doctorReviewed: json["doctor_reviewed"] ?? false,
      requiresEmergencyContact: json["requires_emergency_contact"] ?? false,
      emergencyNotified: json["emergency_notified"] ?? false,
      emergencyNotifiedAt: json["emergency_notified_at"] != null
          ? DateTime.parse(json["emergency_notified_at"])
          : null,
      doctorFeedback: json["doctor_feedback"],
      recommendation: json["recommendation"] ?? "",
    );
  }
}

class DepressionResult {
  final String label;
  final double confidence;

  const DepressionResult({required this.label, required this.confidence});

  bool get isDepressed {
    final normalized = label.trim().toLowerCase();
    return normalized == 'depressed';
  }

  double get confidencePercent => (confidence * 100);
  
  String get safeDisplayLabel => isDepressed
      ? 'Higher depressive indicators detected'
      : 'Emotional balance within normal range';

  String get confidenceDisplay => '${confidencePercent.toStringAsFixed(1)}%';
}

class SentimentResult {
  final String label;
  final double confidence;

  const SentimentResult({required this.label, required this.confidence});

  bool get isPositive => label.toLowerCase() == 'positive';
  double get confidencePercent => (confidence * 100);
  String get confidenceDisplay => '${confidencePercent.toStringAsFixed(1)}%';
}
