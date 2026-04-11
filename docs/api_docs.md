# API & Services Documentation

Since HabitForge operates on Firebase, API interactions are handled via the Firebase SDK directly in the client application.

## 1. Firebase Collections

### Collection: `users`
**Path:** `/users/{uid}`
- `id` (String)
- `email` (String)
- `display_name` (String)
- `subscription_status` (String: "free" | "premium")
- `created_at` (Timestamp)
- `fcm_token` (String?)

### Collection: `habits`
**Path:** `/habits/{habit_id}`
- `habit_id` (String)
- `user_id` (String)
- `title` (String)
- `schedule_type` (String: "daily" | "weekly")
- `schedule_days` (Array of Ints [1,2,3,4,5,6,7])
- `icon` (String)
- `color` (String hex)
- `current_streak` (Int)
- `longest_streak` (Int)

### Collection: `habit_logs`
**Path:** `/habit_logs/{habit_id}_{YYYY-MM-DD}`
- `log_id` (String)
- `habit_id` (String)
- `user_id` (String)
- `date` (Timestamp)
- `completed` (Boolean)

## 2. Cloud Functions
- `dailyCleanup`: Scheduled CRON job running at midnight UTC.
- `onUserDeleted`: Auth trigger. Deletes all relative `habits` and `habit_logs` connected to the `user_id`.

## 3. Client Services (Flutter)
- `AuthService`: Handles register, login, signout, password reset.
- `HabitService`: Handles CRUD for habits and logging functionality. It computes current streaks linearly based on historical log checks.
- `NotificationService`: Handles OS-level local scheduled notifications via `flutter_local_notifications` for exact daily reminders.
