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
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // All days default
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
    
    // Check habit limits for free users
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    final currentUser = await ref.read(authServiceProvider).getUserProfile(user.uid);
    if (currentUser?.subscriptionStatus == 'free') {
      final habitsSnap = await ref.read(habitServiceProvider).getUserHabits(user.uid).first;
      if (habitsSnap.length >= AppConstants.freeHabitLimit) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Free limit reached. Upgrade to Premium for unlimited habits!')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Drink Water',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Why do you want to build this habit?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Text('Icon & Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(_selectedIcon, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: AppConstants.habitIcons.length,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () => setState(() => _selectedIcon = AppConstants.habitIcons[i]),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedIcon == AppConstants.habitIcons[i] ? AppColors.primary : Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(AppConstants.habitIcons[i], style: const TextStyle(fontSize: 18)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: AppConstants.habitColors.length,
                            itemBuilder: (context, i) {
                              final color = Color(int.parse(AppConstants.habitColors[i].replaceFirst('#', '0xFF')));
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = AppConstants.habitColors[i]),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedColor == AppConstants.habitColors[i] ? Colors.white : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: _selectedColor == AppConstants.habitColors[i]
                                      ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]
                                      : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Daily Habit'),
                subtitle: const Text('Do this every day'),
                trailing: Radio<String>(
                  value: 'daily',
                  groupValue: _scheduleType,
                  onChanged: (val) => setState(() => _scheduleType = val!),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Specific Days'),
                subtitle: const Text('Choose which days to do this'),
                trailing: Radio<String>(
                  value: 'weekly',
                  groupValue: _scheduleType,
                  onChanged: (val) {
                    setState(() {
                      _scheduleType = val!;
                      // Reset to all but let user edit
                    });
                  },
                ),
              ),
              if (_scheduleType == 'weekly') ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (i) {
                    final dayInt = i + 1;
                    final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];
                    final isSelected = _selectedDays.contains(dayInt);
                    return ChoiceChip(
                      label: Text(dayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayInt);
                          } else {
                            if (_selectedDays.length > 1) {
                              _selectedDays.remove(dayInt);
                            }
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reminder Notification'),
                subtitle: Text(_reminderTime?.format(context) ?? 'No reminder set'),
                trailing: Switch(
                  value: _reminderTime != null,
                  onChanged: (val) async {
                    if (val) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() => _reminderTime = time);
                    } else {
                      setState(() => _reminderTime = null);
                    }
                  },
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveHabit,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
