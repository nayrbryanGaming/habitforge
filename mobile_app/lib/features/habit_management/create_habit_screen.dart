import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../authentication/auth_provider.dart';
import 'habit_provider.dart';
import '../../core/services/notification_service.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedIcon = AppConstants.habitIcons[0];
  String _selectedColor = AppConstants.habitColors[0];
  String _scheduleType = 'daily';
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    // Check habit limits for free users
    final habitsAsync = ref.read(habitsStreamProvider(user.uid));
    final habitsCount = habitsAsync.value?.length ?? 0;
    final userProfile = ref.read(currentUserProvider).value;
    final isPremium = userProfile?.isPremium ?? false;
    
    if (habitsCount >= AppConstants.freeHabitLimit && !isPremium) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      showModalBottomSheet(
        context: context,
        builder: (context) => const PremiumUpsellSheet(),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    String? reminderTimeStr;
    if (_reminderTime != null) {
      reminderTimeStr = '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}';
    }

    final newHabit = await ref.read(habitNotifierProvider.notifier).createHabit(
      userId: user.uid,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      scheduleType: _scheduleType,
      scheduleDays: _selectedDays,
      icon: _selectedIcon,
      color: _selectedColor,
      reminderTime: reminderTimeStr,
    );

    if (newHabit != null && _reminderTime != null) {
      await _notificationService.scheduleHabitReminder(
        habitId: newHabit.habitId,
        habitTitle: newHabit.title,
        hour: _reminderTime!.hour,
        minute: _reminderTime!.minute,
        days: _selectedDays,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColorValue = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                gradient: LinearGradient(
                  colors: [
                    habitColorValue.withValues(alpha: 0.1),
                    AppColors.backgroundLight,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Liquid Glass AppBar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Forge New Habit',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  background: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              habitColorValue.withValues(alpha: 0.2),
                              AppColors.backgroundLight.withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              GestureDetector(
                                onTap: _showIconPicker,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: habitColorValue.withValues(alpha: 0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(_selectedIcon, style: const TextStyle(fontSize: 40)),
                                  ),
                                ).animate().scale(curve: Curves.easeOutBack),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Primary Info Card
                          _buildPremiumCard(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'What will you forge?',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'The forge needs a name' : null,
                                ),
                                const Divider(height: 1),
                                TextFormField(
                                  controller: _descController,
                                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'Define the routine...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Customization Card
                          _buildSectionCard(
                            title: 'ESTHETICS',
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: AppConstants.habitColors.length,
                                    itemBuilder: (context, i) {
                                      final color = Color(int.parse(AppConstants.habitColors[i].replaceFirst('#', '0xFF')));
                                      final isSelected = _selectedColor == AppConstants.habitColors[i];
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() => _selectedColor = AppConstants.habitColors[i]);
                                        },
                                        child: AnimatedContainer(
                                          duration: 300.ms,
                                          margin: const EdgeInsets.only(right: 14),
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? Colors.white : Colors.transparent,
                                              width: 3,
                                            ),
                                            boxShadow: isSelected
                                              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                                              : null,
                                          ),
                                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextButton.icon(
                                  onPressed: _showTemplatePicker,
                                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                  label: const Text('EXPLORE FORGE TEMPLATES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: habitColorValue,
                                    backgroundColor: habitColorValue.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Consistency Schedule
                          _buildSectionCard(
                            title: 'MOMENTUM',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildEliteTab(
                                        title: 'DAILY',
                                        isSelected: _scheduleType == 'daily',
                                        color: habitColorValue,
                                        onTap: () => setState(() => _scheduleType = 'daily'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildEliteTab(
                                        title: 'SELECT DAYS',
                                        isSelected: _scheduleType == 'weekly',
                                        color: habitColorValue,
                                        onTap: () => setState(() => _scheduleType = 'weekly'),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_scheduleType == 'weekly') ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(7, (i) {
                                      final dayInt = i + 1;
                                      final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];
                                      final isSelected = _selectedDays.contains(dayInt);
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            if (isSelected) {
                                              if (_selectedDays.length > 1) _selectedDays.remove(dayInt);
                                            } else {
                                              _selectedDays.add(dayInt);
                                            }
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: 200.ms,
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isSelected ? habitColorValue : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: isSelected ? habitColorValue : AppColors.border),
                                          ),
                                          child: Center(
                                            child: Text(
                                              dayName,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Reminders
                          _buildSectionCard(
                            title: 'ARCHITECT PROMPT',
                            child: _buildFeatureTile(
                              icon: Icons.notifications_active_outlined,
                              title: 'Scheduled Reminder',
                              subtitle: _reminderTime?.format(context) ?? 'No prompt set',
                              trailing: Switch.adaptive(
                                value: _reminderTime != null,
                                activeColor: habitColorValue,
                                onChanged: (val) async {
                                  if (val) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                                    );
                                    if (time != null) setState(() => _reminderTime = time);
                                  } else {
                                    setState(() => _reminderTime = null);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Safety Disclaimer
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: AppColors.error, size: 22),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'HabitForge is a productivity suite. Consult a health professional before starting physical or clinical routines.',
                                    style: GoogleFonts.inter(
                                      color: AppColors.error.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Primary Action
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveHabit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: habitColorValue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              ),
                              child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                  : const Text(
                                      'BEGIN THE FORGE',
                                      style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900, fontSize: 15),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: 0.05);
  }

  Widget _buildEliteTab({required String title, required bool isSelected, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: 250.ms,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHOOSE YOUR SYMBOL', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11)),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: AppConstants.habitIcons.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedIcon = AppConstants.habitIcons[i]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _selectedIcon == AppConstants.habitIcons[i] ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text(AppConstants.habitIcons[i], style: const TextStyle(fontSize: 28))),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showTemplatePicker() {
    final templates = [
      {'title': 'Morning Sun', 'desc': 'Greet the day with light', 'icon': '🌅', 'color': '#F59E0B'},
      {'title': 'Pure Hydration', 'desc': 'Nourish with 2L water', 'icon': '💧', 'color': '#0ea5e9'},
      {'title': 'Forge Strength', 'desc': '30 mins of intensity', 'icon': '🦾', 'color': '#ef4444'},
      {'title': 'Deep Read', 'desc': 'Consume 30 pages', 'icon': '📖', 'color': '#8b5cf6'},
      {'title': 'Mindful Forge', 'desc': '15 mins of calm', 'icon': '🧘', 'color': '#10b981'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUICK TEMPLATES', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11)),
            const SizedBox(height: 32),
            SizedBox(
              height: 320,
              child: ListView.separated(
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) => ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  tileColor: AppColors.backgroundLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Text(templates[i]['icon']!, style: const TextStyle(fontSize: 24)),
                  ),
                  title: Text(templates[i]['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  subtitle: Text(templates[i]['desc']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _titleController.text = templates[i]['title']!;
                      _descController.text = templates[i]['desc']!;
                      _selectedIcon = templates[i]['icon']!;
                      _selectedColor = templates[i]['color']!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class PremiumUpsellSheet extends StatelessWidget {
  const PremiumUpsellSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 44),
          ),
          const SizedBox(height: 28),
          const Text('UNLIMITED ARCHITECTURE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          const Text(
            'You have reached the initial capacity of 5 habits. Expand the forge to unlock infinite routines and deeper analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('EXPLORE ARCHITECT PLANS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
