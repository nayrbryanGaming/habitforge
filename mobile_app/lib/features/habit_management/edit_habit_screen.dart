import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../models/habit_model.dart';
import 'habit_provider.dart';

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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Habit'),
        centerTitle: true,
      ),
      body: habitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          final habit = habits.firstWhere((h) => h.habitId == widget.habitId);
          _initFields(habit);
          final habitColorValue = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));

          return SingleChildScrollView(
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
                          ),
                        ),
                        const SizedBox(height: 24),
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
                                  initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
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

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _updateHabit(habit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habitColorValue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        shadowColor: habitColorValue.withOpacity(0.4),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SAVE CHANGES', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
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
    );
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

