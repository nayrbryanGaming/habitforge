import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_utils.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isActivating = false;

  void _handleActivation() async {
    setState(() => _isActivating = true);
    HapticFeedback.heavyImpact();
    
    // Simulate activation delay for premium feel
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔥 Welcome to THE FORGE ELITE!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).scale(duration: 10.seconds, begin: const Offset(1, 1), end: const Offset(1.5, 1.5)),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
                          ).animate().shimmer(duration: 2.seconds),
                          const SizedBox(height: 16),
                          const Text(
                            'HABITFORGE ELITE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildFeature(
                        context,
                        Icons.all_inclusive_rounded,
                        'Unlimited Habits',
                        'Break the 5-habit barrier and forge a complete lifestyle transformation.',
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                      _buildFeature(
                        context,
                        Icons.insights_rounded,
                        'Deep Analytics',
                        'Monthly heatmaps and behavioral trend spotting to optimize your forge.',
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                      _buildFeature(
                        context,
                        Icons.sync_rounded,
                        'Cloud Reinforcement',
                        'Real-time encrypted sync keeps your habits safe across all devices.',
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                      _buildFeature(
                        context,
                        Icons.palette_rounded,
                        'Premium Themes',
                        'Lush dark mode variants and custom habit colors for elite aesthetics.',
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                      const SizedBox(height: 40),

                      // Activated Box
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'GLOBAL LAUNCH PERK',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'FREE LIFETIME ACCESS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Claim your spot as an Early Forger and unlock all features for free, forever. No payment information is collected during this early access phase. Future versions may introduce optional premium tiers, but your Early Forger status ensures your current features remain free.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isActivating ? null : _handleActivation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: _isActivating 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'ACTIVATE ELITE STATUS',
                                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Legal Footer (Mandatory for Store Approval)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegalLink('Privacy Policy', () => AppUtils.launchUrl('https://habitforge.app/privacy')),
                          Container(width: 1, height: 12, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _buildLegalLink('Terms of Service', () => AppUtils.launchUrl('https://habitforge.app/terms')),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

