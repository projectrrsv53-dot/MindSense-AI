
// lib/screens/patient/patient_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/analysis_provider.dart';
import '../../router/app_router.dart';

class PatientHistoryScreen extends ConsumerWidget {
  const PatientHistoryScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final history = ref.watch(
      historyProvider,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () => context.go(
            AppRoutes.patientDashboard,
          ),
        ),

        title: const Text(
          "Analysis History",
        ),

        centerTitle: true,
      ),

      body: history.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(),
        ),

        error: (e, _) =>
            Center(
              child: Text(
                e.toString(),
              ),
            ),

        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                "No history found",
              ),
            );
          }

          return ListView.builder(
            itemCount:
            sessions.length,

            itemBuilder:
                (context, index) {
              final s =
              sessions[index];

              return Card(
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                elevation: 2,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                child: ListTile(
                  contentPadding:
                  const EdgeInsets.all(
                    16,
                  ),

                  title: Text(
                    "${s.analysisType.toUpperCase()} Submission",

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 10,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          "Submitted: "
                              "${s.createdAt.day}/"
                              "${s.createdAt.month}/"
                              "${s.createdAt.year} • "
                              "${s.createdAt.hour}:"
                              "${s.createdAt.minute.toString().padLeft(2, '0')}",
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Row(
                          children: [
                            Icon(
                              s.doctorReviewed ? Icons.check_circle : Icons.schedule,
                              size: 18,
                              color: s.doctorReviewed ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                s.doctorReviewed ? "Reviewed" : "Awaiting Review",
                                style: TextStyle(
                                  color: s.doctorReviewed ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push("/patient/session/${s.sessionId}");
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}