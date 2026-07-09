// models/analysis_history_model.dart

class AnalysisHistoryModel {
  final String id;
  final String sessionId;
  final double score;
  final String riskLevel;
  final String analysisType;
  final String transcript;
  final String recommendation;
  final DateTime createdAt;
  final List<Map<String, dynamic>> sharedWith;
  final bool doctorReviewed;

  AnalysisHistoryModel({
    required this.id,
    required this.sessionId,
    required this.score,
    required this.riskLevel,
    required this.analysisType,
    required this.transcript,
    required this.recommendation,
    required this.createdAt,
    required this.sharedWith,
    required this.doctorReviewed,
  });

  factory AnalysisHistoryModel.fromJson(Map<String, dynamic> json) {
    String label = "not depressed";
    double confidence = 0.0;

    if (json["depression"] is Map) {
      confidence = ((json["depression"]["confidence"] ?? 0) as num).toDouble();
      label = (json["depression"]["label"] ?? "non-depressed").toString().trim().toLowerCase();
    } else if (json["fusion_prediction"] is Map) {
      confidence = ((json["fusion_prediction"]["confidence"] ?? 0) as num).toDouble();
      label = (json["fusion_prediction"]["prediction"] ?? "non-depressed").toString().trim().toLowerCase();
    } else if (json["prediction"] is Map) {
      confidence = ((json["prediction"]["confidence"] ?? 0) as num).toDouble();
      label = (json["prediction"]["label"] ?? "non-depressed").toString().trim().toLowerCase();
    }

    if (confidence > 1.0) confidence /= 100.0;
    final bool isDepressed = label == 'depressed';
    final double calculatedScore = isDepressed ? (1 - confidence) * 100 : confidence * 100;

    return AnalysisHistoryModel(
      id: json["id"] ?? json["_id"]?.toString() ?? "",
      sessionId: json["session_id"] ?? json["_id"]?.toString() ?? "",
      score: calculatedScore.clamp(0.0, 100.0),
      riskLevel: json["risk_level"] ?? "LOW",
      analysisType: json["analysis_type"] ?? "",
      transcript: json["transcript"] ?? "",
      recommendation: json["recommendation"] ?? "",
      createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
      sharedWith: (json["shared_with"] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      doctorReviewed: json["doctor_reviewed"] ?? false,
    );
  }
}
