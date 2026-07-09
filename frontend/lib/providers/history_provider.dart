import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/analysis_history_model.dart';
import 'auth_provider.dart';

final historyProvider =
FutureProvider<List<AnalysisHistoryModel>>((ref) async {

  final api = ref.read(apiServiceProvider);

  final auth = ref.read(authProvider);

  if (auth.userId == null) {
    return [];
  }
  debugPrint("History requested for: ${auth.userId}");
  return api.fetchPatientHistory(auth.userId!);
});