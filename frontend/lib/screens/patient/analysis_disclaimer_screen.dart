// lib/screens/patient/analysis_disclaimer_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';

class AnalysisDisclaimerScreen extends ConsumerStatefulWidget {
  const AnalysisDisclaimerScreen({
    super.key,
  });

  @override
  ConsumerState<AnalysisDisclaimerScreen> createState() =>
      _AnalysisDisclaimerScreenState();
}

class _AnalysisDisclaimerScreenState
    extends ConsumerState<AnalysisDisclaimerScreen> {

  bool _loading = true;

  List<dynamic> _doctors = [];

  String? get patientId =>
      ref.read(authProvider).userId;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {

    if (patientId == null) {
      return;
    }

    try {

      final response = await http.get(
        Uri.parse(
          ApiConfig.myDoctors(
            patientId!,
          ),
        ),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(
          response.body,
        );

        setState(() {
          _doctors =
              data["doctors"] ?? [];
        });
      }

    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(
      backgroundColor:
      PatientColors.background,

      appBar: AppBar(
        backgroundColor:
        PatientColors.background,

        title: Text(
          "Analysis Disclaimer",
          style:
          AppTextStyles.headingMedium(),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.patientDashboard);
            }
          },
        ),
      ),

      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : Padding(
        padding:
        const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Container(
              padding:
              const EdgeInsets.all(
                18,
              ),
              decoration:
              BoxDecoration(
                gradient:
                const LinearGradient(
                  colors: [
                    Color(
                      0xFF9B59B6,
                    ),
                    Color(
                      0xFF7C6FCD,
                    ),
                  ],
                ),
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
              child: Row(
                children: [

                  const Text(
                    "🛡️",
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [

                        Text(
                          "Secure Analysis Sharing",
                          style:
                          AppTextStyles
                              .headingSmall(
                            color:
                            Colors
                                .white,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          "Your uploaded analysis will automatically be shared only with the doctors currently connected to your account.",
                          style:
                          AppTextStyles
                              .bodySmall(
                            color:
                            Colors
                                .white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Text(
              "Doctors who will receive this analysis:",
              style:
              AppTextStyles.headingSmall(),
            ),

            const SizedBox(
              height: 16,
            ),

            if (_doctors.isEmpty)
              Container(
                width:
                double.infinity,
                padding:
                const EdgeInsets.all(
                  20,
                ),
                decoration:
                BoxDecoration(
                  color:
                  PatientColors.surface,
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),
                child: Column(
                  children: [

                    const Text(
                      "⚠️",
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "No doctors connected",
                      style:
                      AppTextStyles
                          .headingSmall(),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "You must connect at least one doctor before uploading an analysis.",
                      textAlign:
                      TextAlign.center,
                      style:
                      AppTextStyles
                          .bodySmall(),
                    ),
                  ],
                ),
              ),

            if (_doctors.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount:
                  _doctors.length,

                  itemBuilder:
                      (
                      context,
                      index,
                      ) {

                    final doctor =
                    _doctors[index];

                    return Container(
                      margin:
                      const EdgeInsets.only(
                        bottom:
                        12,
                      ),

                      padding:
                      const EdgeInsets.all(
                        16,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        PatientColors
                            .surface,

                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),

                        border:
                        Border.all(
                          color:
                          PatientColors
                              .divider,
                        ),
                      ),

                      child: Row(
                        children: [

                          const CircleAvatar(
                            radius:
                            24,
                            child:
                            Text(
                              "👨‍⚕️",
                            ),
                          ),

                          const SizedBox(
                            width:
                            14,
                          ),

                          Expanded(
                            child:
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [

                                Text(
                                  doctor["name"] ??
                                      "",
                                  style:
                                  AppTextStyles
                                      .bodyLarge(),
                                ),

                                const SizedBox(
                                  height:
                                  4,
                                ),

                                Text(
                                  doctor["specialization"] ??
                                      "",
                                  style:
                                  AppTextStyles
                                      .bodySmall(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(
              height: 20,
            ),

            if (_doctors.isNotEmpty)
              PrimaryButton(
                label:
                "Continue to Upload",
                gradient:
                PatientColors
                    .mainGradient,

                // onPressed: () {
                //
                //   context.go(
                //     AppRoutes.patientUpload,
                //   );
                // },
                onPressed: () {

                  final uploadType =
                  GoRouterState.of(context)
                      .uri
                      .queryParameters["type"];

                  context.go(
                    "${AppRoutes.patientUpload}?type=${uploadType ?? 'fusion'}",
                  );
                },
              ),

            const SizedBox(
              height: 12,
            ),

            PrimaryButton(
              // label:
              // "Manage Doctors",
              label: "Add Doctor",

              gradient:
              const LinearGradient(
                colors: [
                  Color(
                    0xFF9B59B6,
                  ),
                  Color(
                    0xFF7C6FCD,
                  ),
                ],
              ),

              onPressed: () {

                // context.go(
                //   AppRoutes
                //       .doctorConnect,
                // );
                context.push(
                  AppRoutes
                      .doctorConnect,
                );
              },
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed: () {
                context.go(
                  AppRoutes
                      .patientDashboard,
                );
              },

              child: const SizedBox(
                width:
                double.infinity,

                child: Center(
                  child: Text(
                    "Cancel",
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}