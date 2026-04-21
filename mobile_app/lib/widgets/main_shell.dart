import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:ui';
import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/services/notification_service.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = NotificationService.onNotificationTap.listen((habitId) {
      if (habitId != null && mounted) {
        context.push('/habit/$habitId');
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    int getIndex() {
      if (location == AppRoutes.home) return 0;
      if (location == AppRoutes.analytics) return 1;
      if (location == AppRoutes.profile) return 2;
      return 0;
    }

    return Scaffold(
      extendBody: true,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push(AppRoutes.createHabit);
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: BottomAppBar(
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.8),
              shape: const CircularNotchedRectangle(),
              notchMargin: 10,
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Forge',
                      isSelected: getIndex() == 0,
                      onTap: () => context.go(AppRoutes.home),
                    ),
                    _NavButton(
                      icon: Icons.analytics_outlined,
                      label: 'Mastery',
                      isSelected: getIndex() == 1,
                      onTap: () => context.go(AppRoutes.analytics),
                    ),
                    const SizedBox(width: 48), // Space for FAB
                    _NavButton(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      isSelected: getIndex() == 2,
                      onTap: () => context.go(AppRoutes.profile),
                    ),
                    _NavButton(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isSelected: location == AppRoutes.settings,
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24)
                .animate(target: isSelected ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 200.ms)
                .tint(color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
