# HabitForge API Documentation (Internal)

While HabitForge mostly uses Firebase SDKs, specific logic is encapsulated in **Cloud Functions** and **Riverpod Services**.

## 1. Cloud Functions

### `createHabit` (Client-side trigger)
Direct write to Firestore `habits` collection.

### `updateAnalytics` (On-write trigger)
- **Trigger**: `onCreate` / `onDelete` in `habit_logs`.
- **Action**: Recalculates current streak and completion rates in the `analytics` collection.

### `scheduleReminder` (Pub/Sub)
- **Frequency**: Every 15 minutes.
- **Action**: Checks for habits with `reminder_time` within the next window and sends FCM notifications.

## 2. Riverpod Providers (Core Services)

### `AuthService`
- `signIn(email, password)`
- `signUp(email, password)`
- `signOut()`
- `deleteAccount()`

### `HabitService`
- `getHabits()`: Stream of all user habits.
- `addHabit(Habit habit)`
- `toggleHabit(String habitId, DateTime date)`
- `getAnalytics(String habitId)`

## 3. Firestore Schema

### `users` (Collection)
```json
{
  "id": "String",
  "email": "String",
  "createAt": "Timestamp",
  "isPremium": "Boolean"
}
```

### `habits` (Collection)
```json
{
  "id": "String",
  "userId": "String",
  "title": "String",
  "description": "String",
  "frequency": "daily|weekly",
  "reminderTime": "String (HH:mm)",
  "color": "String (Hex)"
}
```
