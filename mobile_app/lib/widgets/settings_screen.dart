import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../features/authentication/auth_provider.dart';



class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('ACCOUNT'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                subtitle: 'Update your name and profile settings',
                onTap: () {},
                iconColor: AppColors.primary,
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Reminders',
                subtitle: 'Manage your daily Forge prompts',
                onTap: () => context.push(AppRoutes.notifications),
                iconColor: AppColors.primary,
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.star_outline_rounded,
                title: 'HabitForge Premium',
                subtitle: 'Unlock unlimited habits and insights',
                onTap: () => context.push(AppRoutes.premium),
                iconColor: AppColors.streakGold,
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('LEGAL & TRANSPARENCY'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we protect your forge data',
                onTap: () => context.push(AppRoutes.about),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Usage guidelines & agreements',
                onTap: () => context.push(AppRoutes.about),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.security_outlined,
                title: 'Data Usage Policy',
                subtitle: 'Transparent analytics disclosure',
                onTap: () => context.push(AppRoutes.about),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.gavel_outlined,
                title: 'Clinical Disclaimer',
                subtitle: 'Safety & medical information',
                onTap: () => context.push(AppRoutes.about),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.download_done_rounded,
                title: 'Data Portability',
                subtitle: 'Your data belongs to you',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data Export: Every bit of your data is synced to Firebase and can be requested via legal@habitforge.app')),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                trailing: Text(AppConstants.appVersion, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('DANGER ZONE'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(authNotifierProvider.notifier).signOut();
                },
                textColor: AppColors.textSecondary,
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                onTap: () => _showDeleteConfirmation(context, ref),
                iconColor: AppColors.error,
                textColor: AppColors.error,
              ),
            ]),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Atomic Purge?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently destroy:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Your entire habit collection'),
            Text('• All streak and progress data'),
            Text('• Your profile and auth credentials'),
            SizedBox(height: 16),
            Text(
              'This action is IRREVERSIBLE. We cannot recover your forage progress once deleted.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABORT', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(authNotifierProvider.notifier).deleteAccount();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account and data successfully purged.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e. You may need to re-login to delete your account.'),
                      backgroundColor: AppColors.error,
                      action: SnackBarAction(
                        label: 'LOGIN',
                        textColor: Colors.white,
                        onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('PURGE EVERYTHING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

