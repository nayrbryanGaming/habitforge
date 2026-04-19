import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';


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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Architecture & Legal'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const BouncingScrollPhysics(),
        children: [
          const Center(
            child: Column(
              children: [
                Hero(
                  tag: 'app_icon',
                  child: Icon(Icons.hardware, size: 72, color: AppColors.primary),
                ),
                SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                Text(
                  'Production Version ${AppConstants.appVersion}',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildLegalSection(context),
          const SizedBox(height: 32),
          _buildDataTransparency(context),
          const SizedBox(height: 32),
          _buildMedicalDisclaimer(context),
          const SizedBox(height: 60),
          const Center(
            child: Text(
              'Forged with Discipline for Builders.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROTOCOL & COMPLIANCE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        _buildLegalTile(
          context: context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          content: _privacyContent,
        ),
        const Divider(height: 1),
        _buildLegalTile(
          context: context,
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          content: _termsContent,
        ),
        const Divider(height: 1),
        _buildLegalTile(
          context: context,
          icon: Icons.security_outlined,
          title: 'Data Usage Policy',
          content: _dataUsageContent,
        ),
        const Divider(height: 1),
        _buildLegalTile(
          context: context,
          icon: Icons.gavel_outlined,
          title: 'Clinical Disclaimer',
          content: _disclaimerContent,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _launchUrl(AppConstants.websiteUrl),
              icon: const Icon(Icons.language_rounded, size: 14),
              label: const Text('Official Site', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 24),
            TextButton.icon(
              onPressed: () => _launchUrl('mailto:${AppConstants.legalEmail}'),
              icon: const Icon(Icons.email_outlined, size: 14),
              label: const Text('Contact Legal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegalTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: const Text('Clinical standards document', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.border),
      onTap: () => _showLegalDocument(context, title, content),
    );
  }

  void _showLegalDocument(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(backgroundColor: AppColors.backgroundLight),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    Text(
                      content,
                      style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const String _privacyContent = """
PRIVACY POLICY | HabitForge Architecture

1. COMMITMENT TO PRIVACY
HabitForge ("we," "our," or "us") is designed with a core mandate of privacy integrity. We are committed to protecting your personal information in compliance with the Google Play Developer Distribution Agreement.

2. DATA WE PROCESS
- Account Identifiers: Name and E-mail via Google Firebase Auth.
- Habit Metallurgy: Log data, streak metrics, and routine configurations stored in encrypted Cloud Firestore clusters.
- Behavioral Insight: Anonymized engagement metrics via Google Analytics for Firebase.

3. SECURITY STANDARDS
Your data is protected using industry-standard AES-256 encryption at rest and TLS 1.3 encryption in transit.

4. USER SOVEREIGNTY
In accordance with GDPR/CCPA, users maintain full sovereignty over their data. The "Atomic Purge" feature in Settings permanently and irreversibly deletes your profile and all history within 24 hours of execution.

CONTACT: legal@habitforge.app
""";

  static const String _termsContent = """
TERMS OF SERVICE | HabitForge Architecture

1. ARCHITECTURE USAGE
By accessing HabitForge, you acknowledge acceptance of these operational terms. Access is granted for personal use in performance management.

2. ACCOUNT RESPONSIBILITY
Users are the sole architects of their accounts. You are responsible for maintaining the integrity of your authentication credentials.

3. FORGE INTEGRITY
Any attempt to manipulate streak counts or reverse-engineer the "Forge Capacity" metrics via unauthorized API access will result in immediate protocol termination.

4. MONETIZATION
Premium features are provided via Google Play Billing. All transactions are subject to standard Google Play refund policies.

5. TERMINATION
We reserve the right to revoke access to the HabitForge ecosystem for users violating community standards or operational integrity.
""";

  static const String _dataUsageContent = """
DATA USAGE POLICY | HabitForge Architecture

1. PURPOSE OF COLLECTION
Data is utilized exclusively to maintain the operational stability of your habits and to calculate clinical-accuracy behavioral streaks.

2. PUSH NOTIFICATION PROTOCOL
We collect FCM Device Tokens to deliver scheduled habit reminders. These tokens are for transactional notifications only and are never used for marketing purposes by third parties.

3. ANALYTICS & IMPROVEMENTS
Engagement data is harvested in an anonymized aggregate to optimize the Forge UX and identify common behavioral friction points.

4. THIRD-PARTY DISCLOSURE
No user metrics, e-mails, or habit identifiers are ever sold or disclosed to external advertising networks or data brokers.
""";

  static const String _disclaimerContent = """
CLINICAL DISCLAIMER | HabitForge Architecture

1. INFORMATIONAL SCOPE
HabitForge is a productivity and performance-tracking architecture. The insights, templates, and "Forge" psychology provided are for informational and motivational purposes.

2. NOT CLINICAL ADVICE
The app does not provide medical, psychological, or dietary advice. All "Habit Templates" (e.g., Morning HIIT, Fasting) are examples and should be reviewed by a professional before adoption.

3. INDEMNIFICATION
Users assume all risk for physical or psychological changes resulting from routine modification. HabitForge Labs Inc. is not liable for outcomes resulting from the adoption of habit protocols within the app.

4. TERMINOLOGY
Definitions like "Lit," "Forge Capacity," and "Momentum Grid" are psychological framework metaphors and are not scientific measurements.
""";


  Widget _buildDataTransparency(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Safety & Privacy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow(Icons.cloud_done_rounded, 'Cloud Integrity', 'Habit logs, streaks, and analytics are synced via Google Firebase for cross-device resilience.'),
              const Divider(height: 32),
              _buildDataRow(Icons.lock_person_rounded, 'Advanced Encryption', 'All data is encrypted in transit (TLS) and at rest (AES-256).'),
              const Divider(height: 32),
              _buildDataRow(Icons.delete_forever_rounded, 'Atomic Deletion', 'Permanent purge of all personal data, habit logs, and analytics upon account deletion.'),
              const SizedBox(height: 32),
              const Text(
                'COLLECTED DATA TYPES',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildSimpleDataList([
                'Personal Info (Name, Email) - Account MGMT',
                'App Activity (Habit Logs) - App Functionality',
                'Performance (Analytics) - Optimization',
                'Device ID (AdID/UUID) - Analytics',
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDataList(List<String> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(child: Text(item, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDataRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
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
