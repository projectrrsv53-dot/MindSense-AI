// lib/screens/patient/analysis_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';

class AnalysisSuccessScreen extends ConsumerWidget {
  const AnalysisSuccessScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final auth = ref.watch(
      authProvider,
    );

    return Scaffold(
      backgroundColor:
      PatientColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(
            28,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [

              const SizedBox(
                height: 20,
              ),

              const Center(
                child: Text(
                  "🎉",
                  style: TextStyle(
                    fontSize: 80,
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                "Analysis Submitted",
                textAlign:
                TextAlign.center,

                style:
                AppTextStyles
                    .displayMedium(),
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                "Your submission has been securely saved and shared with your connected healthcare professionals.",
                textAlign:
                TextAlign.center,

                style:
                AppTextStyles
                    .bodyLarge(),
              ),

              const SizedBox(
                height: 30,
              ),

              Container(
                width:
                double.infinity,

                padding:
                const EdgeInsets.all(
                  18,
                ),

                decoration:
                BoxDecoration(
                  color:
                  PatientColors
                      .primarySurface,

                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),

                child: Column(
                  children: [

                    const Icon(
                      Icons
                          .shield_outlined,
                      size: 42,
                      color:
                      PatientColors
                          .primary,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      "What happens next?",
                      style:
                      AppTextStyles
                          .headingSmall(),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildStep(
                      "1",
                      "Your analysis session has been saved securely.",
                    ),

                    _buildStep(
                      "2",
                      "Connected doctors can now review your submission.",
                    ),

                    _buildStep(
                      "3",
                      "Your doctor may add notes or recommendations.",
                    ),

                    _buildStep(
                      "4",
                      "You can view doctor feedback from your history screen.",
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              PrimaryButton(
                label:
                "View History",

                gradient:
                PatientColors
                    .mainGradient,

                onPressed: () {
                  context.go(
                    AppRoutes
                        .patientHistory,
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

                child:
                const Padding(
                  padding:
                  EdgeInsets.symmetric(
                    vertical: 14,
                  ),

                  child: Text(
                    "Back to Dashboard",
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              if (auth.userName != null)

                Text(
                  "Thank you, ${auth.userName}.",
                  textAlign:
                  TextAlign.center,

                  style:
                  AppTextStyles
                      .bodySmall(
                    color:
                    PatientColors
                        .textSecondary,
                  ),
                ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
      String number,
      String text,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 14,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          CircleAvatar(
            radius: 14,

            backgroundColor:
            PatientColors
                .primary,

            child: Text(
              number,

              style:
              const TextStyle(
                color:
                Colors.white,
                fontSize: 12,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              text,

              style:
              AppTextStyles
                  .bodyMedium(),
            ),
          ),
        ],
      ),
    );
  }
}