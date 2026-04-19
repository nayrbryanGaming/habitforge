import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/skeleton_container.dart';
import '../../widgets/empty_state_widget.dart';
import '../authentication/auth_provider.dart';
import '../../core/services/notification_service.dart';
import 'habit_provider.dart';
import '../../models/habit_model.dart';
import '../../widgets/glass_card.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Request notification permissions
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        NotificationService().requestPermission();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final todayHabits = ref.watch(todayHabitsProvider(user.uid));

    // Listen for completion to trigger rewards
    ref.listen(todayHabitsProvider(user.uid), (previous, next) {
      next.whenData((habits) {
        if (habits.isNotEmpty) {
          int completedCount = habits.where((h) => h.completed).length;
          double progress = completedCount / habits.length;
          
          if (progress == 1.0 && (previous?.value?.where((h) => h.completed).length ?? 0) < habits.length) {
            _confettiController.play();
            HapticFeedback.vibrate();
            _inAppReview.requestReview();
          }

        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.1),
              elevation: 0,
              toolbarHeight: 100,
              centerTitle: false,
              title: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HABITFORGE',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      'The Forge',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 16),
                  child: Row(
                    children: [
                      _buildAppBarAction(
                        icon: Icons.add_rounded,
                        onTap: () => context.push(AppRoutes.createHabit),
                      ),
                      const SizedBox(width: 12),
                      _buildAppBarAction(
                        icon: Icons.person_outline_rounded,
                        onTap: () => context.push(AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: todayHabits.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 160, 20, 20),
          itemCount: 5,
          itemBuilder: (context, index) => const HabitCardSkeleton(),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          if (habits.isEmpty) {
            return ForgeEmptyState(
              title: 'Empty Anvil',
              subtitle: 'Consistency is the raw material of greatness. Forge your first ritual.',
              icon: '⚒️',
              buttonLabel: 'START THE FORGE',
              onButtonPressed: () => context.push(AppRoutes.createHabit),
            );
          }

          int completedCount = habits.where((h) => h.completed).length;
          double progress = completedCount / habits.length;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  
                  // Premium Mastery Card
                  SliverToBoxAdapter(
                    child: _buildMasteryCard(context, progress, completedCount, habits.length)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                  ),

                  // Habit List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildHabitItem(habits[index], user.uid),
                        childCount: habits.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              
              if (progress == 1.0) _buildCelebrationOverlay(),
              
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [AppColors.primary, AppColors.success, AppColors.gold, Colors.white],

                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBarAction({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.premiumShadow,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMasteryCard(BuildContext context, double progress, int completed, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        color: AppColors.primary,
        opacity: 0.12,
        boxShadow: AppColors.highElevationShadow,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FORGE CAPACITY',
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}% BLAZING',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                  _buildFireBadge(),
                ],
              ),
              const SizedBox(height: 32),
              _buildEliteProgressBar(progress),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    progress == 1.0 ? 'THE ANVIL IS MASTERED!' : '$completed of $total rituals forged today',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFireBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 16),
          SizedBox(width: 4),
          Text(
            'LIT',
            style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds);
  }

  Widget _buildEliteProgressBar(double progress) {
    return Stack(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        AnimatedContainer(
          duration: 1.seconds,
          curve: Curves.easeOutQuart,
          height: 12,
          width: (MediaQuery.of(context).size.width - 104) * progress,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ).animate(target: progress).shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _buildHabitItem(({HabitModel habit, bool completed}) item, String userId) {
    final habitColor = Color(int.parse(item.habit.color.replaceFirst('#', '0xFF')));

    return AnimatedContainer(
      duration: 500.ms,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: item.completed ? Colors.white.withValues(alpha: 0.7) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(
          color: item.completed ? AppColors.success.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => context.push('/habit/${item.habit.habitId}'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildHabitIcon(item.habit.icon, habitColor, item.completed),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.habit.title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: item.completed ? AppColors.textSecondary : AppColors.textPrimary,
                          decoration: item.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.habit.currentStreak > 0 
                                  ? AppColors.streakFire.withValues(alpha: 0.1) 
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 12,
                                  color: item.habit.currentStreak > 0 ? AppColors.streakFire : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.habit.currentStreak} DAY STREAK',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: item.habit.currentStreak > 0 ? AppColors.streakFire : AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildCheckbox(item, userId),
              ],
            ),
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 400.ms, delay: 100.ms)
     .slideX(begin: 0.05);
  }

  Widget _buildHabitIcon(String icon, Color color, bool completed) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: completed ? color.withValues(alpha: 0.08) : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 28)),
      ),
    ).animate(target: completed ? 1 : 0).scale(duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildCheckbox(({HabitModel habit, bool completed}) item, String userId) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(habitNotifierProvider.notifier).toggleHabitCompletion(
              habitId: item.habit.habitId,
              userId: userId,
              date: DateTime.now(),
              completed: !item.completed,
            );
      },
      child: AnimatedContainer(
        duration: 300.ms,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: item.completed ? AppColors.success : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.completed ? AppColors.success : AppColors.border,
            width: 2.5,
          ),
          boxShadow: item.completed ? [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: item.completed 
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.success.withValues(alpha: 0.1), Colors.transparent],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 80)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(duration: 1.seconds)
                  .shimmer(duration: 2.seconds),
            ],
          ),
        ),
      ),
    );
  }
}
