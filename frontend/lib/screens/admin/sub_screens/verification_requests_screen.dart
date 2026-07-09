// lib/screens/admin/sub_screens/verification_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/common/status_badge.dart';

class VerificationRequestsScreen extends ConsumerWidget {
  const VerificationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingDoctorsProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Verification Requests'),
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(pendingDoctorsProvider.notifier).loadPendingDoctors(),
        child: requestsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (requests) {
            final pending = requests.where((r) => r.status == 'pending').toList();
            if (pending.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 64, color: AdminColors.textHint),
                    const SizedBox(height: 16),
                    Text('No pending requests', style: AppTextStyles.headingSmall()),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final request = pending[index];
                return _RequestCard(request: request);
              },
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final dynamic request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.divider),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AdminColors.primarySurface,
                child: Text(request.name[0], style: AppTextStyles.labelMedium(color: AdminColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name, style: AppTextStyles.headingSmall()),
                    Text(request.specialization, style: AppTextStyles.bodySmall()),
                    Text('License: ${request.licenseId}', style: AppTextStyles.bodySmall(color: AdminColors.textHint)),
                  ],
                ),
              ),
              StatusBadge.verificationStatus(request.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleUpdate(context, ref, request.id, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.rejected,
                    side: const BorderSide(color: AdminColors.rejected),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleUpdate(context, ref, request.id, 'approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.approved,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, WidgetRef ref, String id, String status) async {
    final success = await ref.read(pendingDoctorsProvider.notifier).updateStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Update successful' : 'Failed to update request')),
      );
    }
  }
}
