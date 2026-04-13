import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'THE ARCHITECT OF HABIT',
      'description': 'Stop merely tracking. Start forging. Build routines that become your identity through behavioral science.',
      'icon': '🔨',
      'color': '#2563EB',
    },
    {
      'title': 'UNSTOPPABLE MOMENTUM',
      'description': 'Fuel your discipline with streak psychology and hyper-intelligent reminders that never let you skip.',
      'icon': '⚡',
      'color': '#F97316',
    },
    {
      'title': 'DECODE YOUR PROGRESS',
      'description': 'Witness your transformation with high-fidelity heatmaps and deep performance metrics.',
      'icon': '💎',
      'color': '#7C3AED',
    },
  ];

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      HapticFeedback.heavyImpact();
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Gradient decoration
          AnimatedContainer(
            duration: 800.ms,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(int.parse(_pages[_currentPage]['color']!.replaceFirst('#', '0xFF'))).withOpacity(0.05),
                  AppColors.backgroundLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Color(int.parse(page['color']!.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  page['icon']!,
                                  style: const TextStyle(fontSize: 80),
                                ),
                              ),
                            ).animate(key: ValueKey(index)).scale(duration: 600.ms, curve: Curves.backOut).shimmer(delay: 800.ms),
                            const SizedBox(height: 60),
                            Text(
                              page['title']!,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                              textAlign: TextAlign.center,
                            ).animate(key: ValueKey(index)).fadeIn(delay: 200.ms).slideY(begin: 0.2),
                            const SizedBox(height: 16),
                            Text(
                              page['description']!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ).animate(key: ValueKey(index)).fadeIn(delay: 400.ms).slideY(begin: 0.2),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          'Skip',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: 300.ms,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Color(int.parse(_pages[index]['color']!.replaceFirst('#', '0xFF')))
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: 500.ms,
                              curve: Curves.fastOutSlowIn,
                            );
                          } else {
                            _finish();
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(int.parse(_pages[_currentPage]['color']!.replaceFirst('#', '0xFF'))),
                                Color(int.parse(_pages[_currentPage]['color']!.replaceFirst('#', '0xFF'))).withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(int.parse(_pages[_currentPage]['color']!.replaceFirst('#', '0xFF'))).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
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
