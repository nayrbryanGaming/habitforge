# HabitForge API & Data Structure

## 📊 Firestore Schema

### `users`
- `uid`: String (Primary Key)
- `email`: String
- `display_name`: String
- `fcm_token`: String
- `created_at`: Timestamp

### `habits`
- `habit_id`: String
- `user_id`: String (Foreign Key)
- `title`: String
- `icon`: String
- `color`: String
- `reminder_time`: String (HH:mm)
- `schedule_type`: String (daily/weekly)
- `is_active`: Boolean

### `habit_logs`
- `log_id`: String
- `habit_id`: String
- `user_id`: String
- `date`: String (yyyy-MM-dd)
- `status`: String (completed/skipped)

## ⚡ Cloud Functions

### `dailyReminderScheduler`
- **Trigger**: Pub/Sub (Every 1 minute)
- **Logic**: Scans for habits with current `reminder_time` and sends FCM notifications.

### `onUserDeleted`
- **Trigger**: Auth User Delete
- **Logic**: Performs a batch delete of all habits, logs, and analytics for the user.
