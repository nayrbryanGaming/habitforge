import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../features/authentication/auth_provider.dart';
import '../features/habit_management/habit_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white24,
                            child: Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ).animate().scale(duration: 600.ms, curve: Curves.backOut),
                          const SizedBox(height: 12),
                          Text(
                            user.displayName,
                            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                          ).animate().fadeIn(delay: 200.ms),
                          Text(
                            user.email,
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => context.push(AppRoutes.settings),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(ref, user.uid),
                        const SizedBox(height: 32),
                        Text(
                          'Account Management',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsItem(
                          context,
                          Icons.star,
                          'Upgrade to Premium',
                          'Unlock unlimited habits and insights',
                          onTap: () => context.push(AppRoutes.premium),
                          trailing: const Icon(Icons.chevron_right),
                          iconColor: AppColors.streakGold,
                        ),
                        const Divider(),
                        _buildSettingsItem(
                          context,
                          Icons.notifications_outlined,
                          'Notification Settings',
                          'Manage your daily reminders',
                          onTap: () => context.push(AppRoutes.notifications),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                        const Divider(),
                        _buildSettingsItem(
                          context,
                          Icons.logout,
                          'Logout',
                          'Sign out of your account',
                          onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
                        ),
                        const Divider(),
                        _buildSettingsItem(
                          context,
                          Icons.delete_forever,
                          'Delete Account',
                          'Permanently remove all your data',
                          onTap: () => _showDeleteConfirmation(context, ref),
                          iconColor: AppColors.error,
                          textColor: AppColors.error,
                        ),
                        const SizedBox(height: 48),
                        const Center(
                          child: Text(
                            'HabitForge v1.0.0 (Build 8)',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsRow(WidgetRef ref, String userId) {
    final habitsAsync = ref.watch(habitsStreamProvider(userId));
    
    return habitsAsync.when(
      data: (habits) {
        final totalHabits = habits.length;
        final activeStreaks = habits.where((h) => h.currentStreak > 0).length;
        final bestStreak = habits.fold<int>(0, (prev, h) => h.longestStreak > prev ? h.longestStreak : prev);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatItem(label: 'Habits', value: '$totalHabits'),
            _StatItem(label: 'Active', value: '$activeStreaks'),
            _StatItem(label: 'Best Streak', value: '$bestStreak'),
          ],
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
      },
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Text('Error loading stats'),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and will delete all your habits, streaks, and progress records. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

