import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';

final doctorAvailabilityProvider =
FutureProvider.family<
    Map<String, dynamic>,
    String>(
      (
      ref,
      doctorId,
      ) async {

    return await ApiService()
        .getDoctorAvailability(
      doctorId,
    );
  },
);