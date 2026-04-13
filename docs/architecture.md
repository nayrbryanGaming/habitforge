# HabitForge Architecture Guide

**System Overview**
HabitForge is built using a modern, scalable, and modular architecture. It leverages Flutter for the front-end and Firebase for the back-end services.

## 1. Technical Stack
- **Frontend**: Flutter (Dart)
- **State Management**: Riverpod (Modular, testable, and reactive)
- **Navigation**: GoRouter (Declarative, deep-link ready)
- **Backend**: Firebase (Auth, Firestore, Messaging, Functions, Analytics)
- **Styling**: Google Fonts (Inter), Flutter Animate, Custom Glassmorphic components.

## 2. Project Structure
The mobile app follows a **Feature-based Modular Architecture**:
```text
lib/
├── core/         # Shared logic (Theme, Router, Services, Constants, Utils)
├── features/     # Business logic split by domain
│   ├── auth/
│   ├── habits/
│   ├── tracking/
│   ├── analytics/
│   └── profile/
├── models/       # Data transfer objects and entities
├── widgets/      # Shared UI components (Common buttons, cards, etc.)
└── main.dart     # Entry point
```

### 7. Security Layer
- **Firestore Rules**: Granular user-isolation. No user can access or modify another user's habits or logs.
- **Storage Rules**: Ownership-based asset protection for profile media.
- **Authentication**: JWT-based identity management via Firebase Auth.

### 8. Performance & Offline Resilience
- **Hive Caching**: Local-first data architecture. The app remains fully functional during network drops.
- **Skeleton Views**: Shimmer-based UI feedback during initial data hydration.
- **Image Optimization**: Cached network images with progressive loading.

### 9. Reliability
- **runZonedGuarded**: Global exception handling for production stability.
- **Firebase Analytics**: Real-time monitoring of user engagement and error rates.

## 3. Data Flow
1. **Source**: Firestore (Real-time streams)
2. **Provider**: Riverpod (Listens to Firestore and manages UI state)
3. **UI**: Consumes providers and triggers actions back to Firestore.

## 4. Backend Services (Firebase)
- **Authentication**: Email/Password and Anonymous login with permanent account conversion.
- **Firestore Collections**:
    - `users`: Profile data, subscription status.
    - `habits`: Definitions of user habits.
    - `habit_logs`: Daily history of completions.
    - `analytics`: Aggregated summaries (weekly/monthly).
- **Cloud Functions**:
    - `dailyNotificationScheduler`: Triggers notifications for due habits.
    - `onUserDeleted`: Ensures full data removal for policy compliance.

## 5. Security Rules
We implement strict Firestore Security Rules to ensure:
- Users can only read/write their own data.
- Input validation (e.g., preventing duplicate log dates).
- Restricted access to the `analytics` collection.
