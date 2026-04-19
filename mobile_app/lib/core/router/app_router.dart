import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/auth_provider.dart';
import '../constants/app_routes.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/authentication/forgot_password_screen.dart';
import '../../features/habit_management/home_screen.dart';
import '../../features/habit_management/create_habit_screen.dart';
import '../../features/habit_management/habit_detail_screen.dart';
import '../../features/habit_management/edit_habit_screen.dart';
import '../../features/analytics_dashboard/analytics_screen.dart';
import '../../features/reminders/notifications_screen.dart';
import '../../widgets/splash_screen.dart';
import '../../widgets/onboarding_screen.dart';
import '../../widgets/main_shell.dart';
import '../../features/profile/profile_screen.dart';
import '../../widgets/premium_screen.dart';

import '../../widgets/settings_screen.dart';
import '../../widgets/about_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoading = authState.isLoading;

      if (isLoading) return AppRoutes.splash;

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && (state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createHabit,
        builder: (context, state) => const CreateHabitScreen(),
      ),
      GoRoute(
        path: AppRoutes.habitDetail,
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitDetailScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: AppRoutes.editHabit,
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return EditHabitScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});
