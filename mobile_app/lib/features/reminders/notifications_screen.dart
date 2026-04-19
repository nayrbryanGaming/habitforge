import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';

import '../../features/analytics_dashboard/forge_settings_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    // Show rationale dialog first to satisfy Google Play reviewers
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Forge Reminders'),
        content: const Text(
          'HabitForge needs notification access to send you daily nudges, streak alerts, and achievement celebrations. This is crucial for maintaining your consistency.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('LATER'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ENABLE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (proceed == true) {
      final status = await Permission.notification.request();
      setState(() {
        _notificationsEnabled = status.isGranted;
      });
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notifications are disabled in system settings.'),
              action: SnackBarAction(
                label: 'SETTINGS',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    }
  }

  void _sendTestNotification() {
    HapticFeedback.mediumImpact();
    // Simulate a foreground notification via the service
    _notificationService.scheduleHabitReminder(
      habitId: 'test_id',
      habitTitle: 'Morning Meditation 🧘',
      hour: DateTime.now().hour,
      minute: DateTime.now().minute + 1,
      days: [DateTime.now().weekday],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification scheduled for 1 minute from now! 🔥'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(forgeSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notificationsEnabled)
            TextButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('TEST'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: AppColors.primary, size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Reminders',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Stay consistent with timely nudges.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val) {
                      _requestPermission();
                    } else {
                      // Logic to clear all reminders if needed
                      setState(() => _notificationsEnabled = false);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Active Reminders',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _EmptyNotifications(),
          const SizedBox(height: 32),
          Text(
            'Notification Types',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTypeToggle(
            ref,
            'Daily Digests',
            'Get a morning summary of your forging goals.',
            settings.dailyDigests,
            (val) => ref.read(forgeSettingsProvider.notifier).toggleDailyDigests(val),
          ),
          const Divider(),
          _buildTypeToggle(
            ref,
            'Streak Warnings',
            'Alerts when you are about to lose a long streak.',
            settings.streakWarnings,
            (val) => ref.read(forgeSettingsProvider.notifier).toggleStreakWarnings(val),
          ),
          const Divider(),
          _buildTypeToggle(
            ref,
            'Achievement Alerts',
            'Celebrate when you forge a new milestone.',
            settings.achievementAlerts,
            (val) => ref.read(forgeSettingsProvider.notifier).toggleAchievementAlerts(val),
          ),
          const SizedBox(height: 24),
          if (!_notificationsEnabled)
            const Center(
              child: Text(
                'Enable push reminders above to stay on track.',
                style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(WidgetRef ref, String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Checkbox(
        value: value,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (val) {
          if (val != null) {
            HapticFeedback.selectionClick();
            onChanged(val);
          }
        },
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No Active Reminders',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enable reminders when creating or editing a habit to see them here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

