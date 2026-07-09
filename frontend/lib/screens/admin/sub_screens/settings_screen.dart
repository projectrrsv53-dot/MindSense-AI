// lib/screens/admin/sub_screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenanceMode = false;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('General Configuration'),
          _SettingTile(
            title: 'Maintenance Mode',
            subtitle: 'Disable public access to the platform',
            icon: Icons.construction_rounded,
            trailing: Switch(
              value: _maintenanceMode,
              activeColor: AdminColors.accent,
              onChanged: (v) => setState(() => _maintenanceMode = v),
            ),
          ),
          _SettingTile(
            title: 'Email Notifications',
            subtitle: 'Receive system alerts and logs via email',
            icon: Icons.email_outlined,
            trailing: Switch(
              value: _emailNotifications,
              activeColor: AdminColors.accent,
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Security & API'),
          _SettingTile(
            title: 'API Configuration',
            subtitle: 'Manage backend environment variables',
            icon: Icons.api_rounded,
            trailing: const Icon(Icons.chevron_right, color: AdminColors.textHint),
            onTap: () => _showComingSoon(context),
          ),
          _SettingTile(
            title: 'Audit Logs',
            subtitle: 'View detailed system interaction logs',
            icon: Icons.list_alt_rounded,
            trailing: const Icon(Icons.chevron_right, color: AdminColors.textHint),
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Advanced'),
          _SettingTile(
            title: 'Clear Cache',
            subtitle: 'Delete all temporary system data',
            icon: Icons.delete_sweep_outlined,
            trailing: const Icon(Icons.chevron_right, color: AdminColors.textHint),
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 48),
          Column(
            children: [
              const Icon(Icons.verified_user_rounded, color: AdminColors.textHint, size: 40),
              const SizedBox(height: 8),
              Text('MindSense AI Admin Panel', style: AppTextStyles.labelMedium(color: AdminColors.textHint)),
              Text('Version: 1.0.0 (Stable)', style: AppTextStyles.bodySmall(color: AdminColors.textHint)),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall(color: AdminColors.textSecondary).copyWith(letterSpacing: 1.2),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon')),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AdminColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AdminColors.primary, size: 22),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium(color: AdminColors.textPrimary).copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall()),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
