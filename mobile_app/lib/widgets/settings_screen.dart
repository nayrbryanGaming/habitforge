import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About HabitForge'),
            subtitle: const Text('Legal, Privacy, and Disclaimers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}
