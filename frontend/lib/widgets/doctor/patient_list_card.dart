// lib/widgets/doctor/patient_list_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/status_badge.dart';
import '../../models/patient_model.dart';

class PatientListCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const PatientListCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color riskColor = AppColors.getRiskColor(patient.riskLevel);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DoctorColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: riskColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: riskColor.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              _PatientAvatar(name: patient.name, riskLevel: patient.riskLevel),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.name,
                            style: AppTextStyles.headingSmall(color: DoctorColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge.risk(patient.riskLevel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.age} • ${patient.gender} • ${patient.sessionCount} sessions',
                      style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: DoctorColors.textHint),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Last: ${patient.lastSessionDisplay}',
                            style: AppTextStyles.bodySmall(color: DoctorColors.textHint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (patient.hasGrantedAccess) ...[
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded,
                                  size: 12, color: DoctorColors.success),
                              const SizedBox(width: 4),
                              Text(
                                'Access',
                                style: AppTextStyles.bodySmall(color: DoctorColors.success),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: DoctorColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  final String name;
  final String riskLevel;

  const _PatientAvatar({required this.name, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final Color ringColor = AppColors.getRiskColor(riskLevel);
    
    String initials = '??';
    final cleanName = name.trim();
    if (cleanName.isNotEmpty) {
      final parts = cleanName.split(' ');
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (cleanName.length >= 2) {
        initials = cleanName.substring(0, 2).toUpperCase();
      } else {
        initials = cleanName.toUpperCase();
      }
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2),
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: DoctorColors.primarySurface,
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.labelMedium(color: DoctorColors.primary).copyWith(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
