const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Scheduled function to run every day to trigger reminders
// In a high-traffic app, this would use FCM batches or Cloud Tasks
// Scheduled function to run every minute to trigger habit reminders
// This ensures precision for reminder_time (e.g., 08:30)
exports.dailyReminderScheduler = functions.pubsub.schedule("* * * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    const now = new Date();
    // Weekday check: JavaScript 0 is Sunday, 6 is Saturday.
    // Our app uses 1 (Mon) to 7 (Sun).
    const currentWeekday = now.getUTCDay() === 0 ? 7 : now.getUTCDay();
    const currentHour = now.getUTCHours().toString().padStart(2, "0");
    const currentMinute = now.getUTCMinutes().toString().padStart(2, "0");
    const currentTimeStr = `${currentHour}:${currentMinute}`;

    console.log(`Checking for reminders at ${currentTimeStr} (Day: ${currentWeekday})`);

    // Fetch active habits with reminders set for this exact time
    const habitsSnapshot = await db.collection("habits")
      .where("reminder_time", "==", currentTimeStr)
      .where("is_active", "==", true)
      .get();

    if (habitsSnapshot.empty) return null;

    const messages = [];
    const userTokens = new Map();

    for (const doc of habitsSnapshot.docs) {
      const habit = doc.data();
      
      // Only remind if habit is scheduled for today
      const isScheduledToday = habit.schedule_type === "daily" || 
                               (habit.schedule_days && habit.schedule_days.includes(currentWeekday));
      
      if (!isScheduledToday) continue;

      const userId = habit.user_id;

      // Cache user tokens to avoid redundant reads
      if (!userTokens.has(userId)) {
        const userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.exists) {
          userTokens.set(userId, userDoc.data().fcm_token);
        }
      }

      const token = userTokens.get(userId);
      if (token) {
        messages.push({
          token: token,
          notification: {
            title: "HabitForge: Forge Time! 🔨",
            body: `Don't break your streak! Time to work on: ${habit.title}`,
          },
          data: {
            habitId: doc.id,
            type: "HABIT_REMINDER",
            click_action: "FLUTTER_NOTIFICATION_CLICK"
          },
        });
      }
    }

    if (messages.length === 0) return null;

    try {
      // Send up to 500 messages in one call (Firebase Admin SDK limit)
      const response = await admin.messaging().sendEach(messages);
      console.log(`Reminders: Sent ${response.successCount}, Failed ${response.failureCount}`);
    } catch (error) {
      console.error("FCM Batch Error:", error);
    }
    return null;
  });


// Triggered when a new user signs up
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  console.log(`New user created: ${user.uid}`);
  // Add any specific default data here if needed that wasn't done on client
  return null;
});

// Triggered on user deletion to clean up associated records
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  console.log(`Cleaning up data for deleted user: ${uid}`);
  
  const batch = db.batch();
  
  // Delete habits
  const habitsSnapshot = await db.collection("habits").where("user_id", "==", uid).get();
  habitsSnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // Delete logs
  const logsSnapshot = await db.collection("habit_logs").where("user_id", "==", uid).get();
  logsSnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // Delete analytics
  const analyticsSnapshot = await db.collection("analytics").where("user_id", "==", uid).get();
  analyticsSnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // Delete user document
  const userRef = db.collection("users").doc(uid);
  batch.delete(userRef);

  await batch.commit();
  console.log(`Cleanup complete for user: ${uid}`);
  return null;
});

