import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/habit_model.dart';
import '../authentication/auth_provider.dart';
import 'habit_provider.dart';
import '../../core/services/notification_service.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final String habitId;

  const EditHabitScreen({super.key, required this.habitId});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedIcon = AppConstants.habitIcons[0];
  String _selectedColor = AppConstants.habitColors[0];
  String _scheduleType = 'daily';
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  TimeOfDay? _reminderTime;
  bool _isLoading = false;
  bool _isInitialized = false;

  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _initFields(HabitModel habit) {
    if (_isInitialized) return;
    _titleController.text = habit.title;
    _descController.text = habit.description;
    _selectedIcon = habit.icon;
    _selectedColor = habit.color;
    _scheduleType = habit.scheduleType;
    _selectedDays = List.from(habit.scheduleDays);
    
    if (habit.reminderTime != null) {
      final parts = habit.reminderTime!.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
    _isInitialized = true;
  }

  void _updateHabit(HabitModel originalHabit) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    String? reminderTimeStr;
    if (_reminderTime != null) {
      reminderTimeStr = '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}';
    }

    final updatedHabit = originalHabit.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      scheduleType: _scheduleType,
      scheduleDays: _selectedDays,
      icon: _selectedIcon,
      color: _selectedColor,
      reminderTime: reminderTimeStr,
    );

    await ref.read(habitNotifierProvider.notifier).updateHabit(updatedHabit);

    // Update notifications
    await _notificationService.cancelHabitReminder(widget.habitId);
    if (_reminderTime != null) {
      await _notificationService.scheduleHabitReminder(
        habitId: widget.habitId,
        habitTitle: updatedHabit.title,
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
    final authState = ref.watch(authStateProvider);
    final habitAsync = ref.watch(habitsStreamProvider(authState.value?.uid ?? ''));

    return habitAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (habits) {
        final habitIndex = habits.indexWhere((h) => h.habitId == widget.habitId);
        if (habitIndex == -1) return const Scaffold(body: Center(child: Text('Habit not found')));
        
        final habit = habits[habitIndex];
        _initFields(habit);
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
                        'Reforge Habit',
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
                                        hintText: 'What will you reforge?',
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
                                        hintText: 'Refine the routine...',
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
                                          initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
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
                                  onPressed: _isLoading ? null : () => _updateHabit(habit),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: habitColorValue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  ),
                                  child: _isLoading 
                                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                      : const Text(
                                          'SAVE CHANGES',
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
      },
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
}
