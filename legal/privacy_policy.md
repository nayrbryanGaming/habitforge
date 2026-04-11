# Privacy Policy for HabitForge

**Effective Date:** April 11, 2026

## 1. Information We Collect
**1.1 Data you provide:** When you register for HabitForge, we collect your email address, display name, and securely hashed passwords (handled via Firebase Authentication).
**1.2 Usage Data:** We collect interactions within the app (habit creation, logs, streaks) to provide analytical insights.
**1.3 Device Data:** We may collect device info, OS versions, and FCM tokens to deliver push notifications properly.

## 2. How We Use Information
- To provide and maintain the HabitForge service.
- To sync your habit data across devices using Cloud Firestore.
- To send daily smart reminders via Firebase Cloud Messaging.
- To calculate and display personalized statistical insights.

## 3. Data Storage and Security
All user data is stored securely on Google Cloud Platform via Firebase. We implement robust security rules to ensure that a user can only read and write their own data. No third party has direct access to our Firestore database.

## 4. User Rights and Deletion Process
You have the right to access, edit, or delete your data at any time.
- **Account Deletion:** You can delete your account directly inside the app (Profile -> Settings -> Delete Account).
- **Data Erasure:** Upon account deletion, a backend Cloud Function automatically erases all associated habit records and logs from our servers within 24 hours.

## 5. Google Play Store Compliance
HabitForge fully complies with the Google Play Developer Program Policies. We do not sell your personal data to third-party ad networks.

## 6. Contact Us
For privacy concerns, email: privacy@habitforge.app
