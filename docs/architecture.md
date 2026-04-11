# System Architecture

## Overview
HabitForge utilizes a serverless architecture designed for rapid iteration, infinite scalability, and low operational overhead. 

### 1. Frontend (Flutter)
- **Framework:** Flutter (latest stable). Cross-platform UI compilation.
- **State Management:** Riverpod. Used for its compile-time safety and scalable dependency injection model.
- **Routing:** GoRouter for declarative, path-based routing (handling auth redirects safely).
- **Architecture Pattern:** Feature-first (Features contain their own logic, screens, and localized providers. Shared utilities live in `core`).

### 2. Backend (Firebase)
- **Authentication:** Firebase Auth (Email/Password).
- **Database:** Cloud Firestore (NoSQL, realtime).
- **Data Model:**
  - `users`: Core profile data and subscription states.
  - `habits`: Habit definitions and global streak metadata.
  - `habit_logs`: Time-series data of habit completions to ensure high-performance querying without locking habit documents.
- **Functions:** Node.js Cloud Functions. Responsible for heavy data cleanup (e.g., cascading deletes when a user destroys an account) and complex daily CRON aggregations.
- **Messaging:** FCM (Firebase Cloud Messaging) for local and pushed reminders.

## Data Flow Mapping
1. **User action** modifies local Riverpod state.
2. **Provider** triggers Firestore write.
3. **Firestore Snapshot** listener streams new data back to Riverpod instantly (Optimistic UI approach).
4. **Cloud Function** listens to Firestore `onCreate/onUpdate` triggers to run async aggregations without blocking the client.
