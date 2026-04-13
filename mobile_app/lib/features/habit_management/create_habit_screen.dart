import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final theme = Theme.of(context);
    final habitColorValue = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('New Habit'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header Segment
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showIconPicker(),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: habitColorValue.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: habitColorValue.withOpacity(0.2), width: 4),
                        ),
                        child: Center(
                          child: Text(_selectedIcon, style: const TextStyle(fontSize: 48)),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.backOut),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () => _showTemplatePicker(),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text('BROWSE TEMPLATES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: AppColors.primary.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Habit Name',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Forgers need a name' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Customization Card
              _buildSectionCard(
                title: 'PERSONALIZE',
                child: Column(
                  children: [
                    const Text('Color Theme', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.habitColors.length,
                        itemBuilder: (context, i) {
                          final color = Color(int.parse(AppConstants.habitColors[i].replaceFirst('#', '0xFF')));
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedColor = AppConstants.habitColors[i]);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 44,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor == AppConstants.habitColors[i] ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: _selectedColor == AppConstants.habitColors[i]
                                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                                  : null,
                              ),
                              child: _selectedColor == AppConstants.habitColors[i]
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Schedule Card
              _buildSectionCard(
                title: 'RECURRENCE',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Daily',
                            isSelected: _scheduleType == 'daily',
                            onTap: () => setState(() => _scheduleType = 'daily'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Weekly',
                            isSelected: _scheduleType == 'weekly',
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
                            child: Container(
                              width: 38,
                              height: 38,
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
                                    fontWeight: FontWeight.bold,
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

              // Reminder Card
              _buildSectionCard(
                title: 'NOTIFICATIONS',
                child: Column(
                  children: [
                    _buildFeatureTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Daily Reminder',
                      subtitle: _reminderTime?.format(context) ?? 'Forge without distractions',
                      trailing: Switch(
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: habitColorValue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: habitColorValue.withOpacity(0.4),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('FORGE HABIT', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
                ),
              ).animate().slideY(begin: 0.1, duration: 600.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.05);
  }

  Widget _buildTypeButton({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CHOOSE ICON', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: AppConstants.habitIcons.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  setState(() => _selectedIcon = AppConstants.habitIcons[i]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _selectedIcon == AppConstants.habitIcons[i] ? AppColors.primary : Colors.transparent),
                  ),
                  child: Center(child: Text(AppConstants.habitIcons[i], style: const TextStyle(fontSize: 24))),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.star, color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 24),
          const Text('UNLIMITED FORGING', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'You\'ve reached the free limit of 5 habits. Upgrade to Premium to forge unlimited routines and access deep analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('VIEW PLANS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  void _showTemplatePicker() {
    final templates = [
      {'title': 'Morning Meditation', 'desc': 'Start the day with clarity', 'icon': '🧘', 'color': '#8B5CF6'},
      {'title': 'Deep Hydration', 'desc': 'Drink 8 glasses of water', 'icon': '💧', 'color': '#06B6D4'},
      {'title': '7-Minute Workout', 'desc': 'High intensity movement', 'icon': '🏃', 'color': '#EF4444'},
      {'title': 'Deep Work Session', 'desc': 'Focus for 90 minutes', 'icon': '🎯', 'color': '#2563EB'},
      {'title': 'Read 20 Pages', 'desc': 'Continuous learning', 'icon': '📚', 'color': '#F97316'},
      {'title': 'Daily Journal', 'desc': 'Reflect on your progress', 'icon': '✍️', 'color': '#F59E0B'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FORGE TEMPLATES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: AppColors.backgroundLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  leading: Text(templates[i]['icon']!, style: const TextStyle(fontSize: 24)),
                  title: Text(templates[i]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(templates[i]['desc']!, style: const TextStyle(fontSize: 12)),
                  onTap: () {
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
