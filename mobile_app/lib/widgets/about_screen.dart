import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // These should ideally point to your hosted domain
  static const String privacyUrl = 'https://habitforge.app/privacy';
  static const String termsUrl = 'https://habitforge.app/terms';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About HabitForge')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.hardware, size: 64, color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'HabitForge',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Version 1.0.0 (Build 8)'),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildLegalSection(context),
          const SizedBox(height: 32),
          _buildMedicalDisclaimer(context),
          const SizedBox(height: 48),
          const Center(
            child: Text(
              'Made with ❤️ for Consistency',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () => _launchUrl(privacyUrl),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () => _launchUrl(termsUrl),
        ),
      ],
    );
  }

  Widget _buildMedicalDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Medical Disclaimer',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'HabitForge is a productivity tool and does not provide medical advice. Consult a healthcare professional before starting any new health or fitness routine. Never disregard professional medical advice because of something you read or tracked in this app.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
