# HabitForge Architecture

## 🏗 System Overview
HabitForge is built using a **Feature-Based Modular Architecture**. This ensures that each domain (Authentication, Habit Management, Analytics, etc.) is isolated, testable, and maintainable.

## 📱 Frontend (Flutter)
- **State Management**: Riverpod. We use `AsyncValue` to handle loading and error states gracefully.
- **Service Layer**: Handles communication with Firebase and Local Storage (Hive).
- **Presentation Layer**: Pure UI components that listen to Riverpod providers.

## ☁️ Backend (Firebase)
- **Authentication**: Atomic account lifecycle management.
- **Firestore**: NoSQL document storage with structured collections for Habits, Logs, and Analytics.
- **Cloud Functions**: Handles background tasks like reminder scheduling and data cleanup.

## 🔒 Data Safety & Privacy
- **Encryption**: Data is encrypted at rest (AES-256) and in transit (TLS).
- **Account Deletion**: Atomic purge of all user data across all collections.
