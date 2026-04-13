# Data Usage Policy for HabitForge

**Last Updated: April 13, 2026**

This policy fulfills Google Play Store Data Safety disclosure requirements and explains transparently how HabitForge collects, uses, protects, and deletes your personal data.

---

## 1. Data We Collect

| Data Type | Collected? | Purpose |
|---|---|---|
| Email Address | ✅ Yes | Account creation and password recovery |
| Display Name | ✅ Yes | Personalizing your experience |
| Habit Titles & Descriptions | ✅ Yes | Core habit tracking functionality |
| Habit Log History | ✅ Yes | Calculating streaks and completion rates |
| Reminder Times | ✅ Yes | Triggering push notifications |
| FCM Device Token | ✅ Yes | Delivering push notifications |
| Anonymous Usage Analytics | ✅ Yes | Improving app performance and UX |
| Precise Location | ❌ No | Not collected |
| Contacts / Phone Number | ❌ No | Not collected |
| Payment Information | ❌ No | Processed by Google Play, not us |

---

## 2. How We Use Your Data

- **Providing the Service**: Your habits, logs, and preferences power the core tracking and analytics features.
- **Push Notifications**: Reminder times are used exclusively to send you timely habit prompts.
- **Analytics**: Aggregate, anonymized data helps us understand which features are most valuable and fix bugs.
- **Account Recovery**: Your email is used for password resets only.

We **NEVER** use your data for advertising profiling, selling to third parties, or any purpose outside the Service.

---

## 3. Data Storage & Security

- All user data is stored in **Google Cloud Firestore** (Firebase) with owner-only access security rules.
- Authentication is managed by **Firebase Authentication** (industry-standard OAuth 2.0 flows).
- All data in transit is encrypted using **HTTPS/TLS 1.3**.
- Firestore security rules ensure strict owner-only data access — no user can read another user's data.

---

## 4. Data Sharing

We **DO NOT** sell or rent your personal data. Data is shared **only** with:
- **Google Firebase** (Firebase Auth, Firestore, FCM, Analytics) — for core service delivery.
- **No other third parties.**

---

## 5. Data Retention

| Scenario | Retention Period |
|---|---|
| Active Account | Data is retained as long as account is active |
| Account Deleted by User | **Immediately and permanently purged** |
| Backups | Purged within 30 days of deletion request |
| Analytics (anonymized) | May be retained indefinitely in aggregate form |

---

## 6. Your Rights & Controls

You have full control over your data:

- ✅ **Access**: View all your habit data directly within the app.
- ✅ **Edit**: Modify any habit, description, or schedule at any time.
- ✅ **Delete Habits**: Delete individual habits and their entire log history.
- ✅ **Delete Account**: Permanently erase your account and ALL associated data.
  - **In-App**: Settings → Danger Zone → Delete Account (takes effect immediately).
  - **Web**: Submit a request at **https://habitforge.app/#data-safety**
  - **Email**: Contact **support@habitforge.app** with your registered email.

---

## 7. Children's Privacy

HabitForge is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If we discover that a child under 13 has provided personal data, we will immediately delete it.

---

## 8. Data Safety on Google Play

This application's Data Safety section on the Google Play Store accurately reflects this policy. No data is collected that is not disclosed above.

---

## 9. Contact Us

For any data-related inquiries:
- **Email**: privacy@habitforge.app
- **Data Deletion Requests**: support@habitforge.app
- **Website**: https://habitforge.app/contact
