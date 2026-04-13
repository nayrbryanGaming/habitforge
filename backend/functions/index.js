const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Scheduled function to run every day to trigger reminders
// In a high-traffic app, this would use FCM batches or Cloud Tasks
exports.dailyReminderScheduler = functions.pubsub.schedule("0 * * * *") // Runs every hour
  .timeZone("UTC")
  .onRun(async (context) => {
    const now = new Date();
    const currentHour = now.getHours().toString().padLeft(2, "0");
    const currentMinute = now.getMinutes().toString().padLeft(2, "0");
    const currentTimeStr = `${currentHour}:${currentMinute}`;

    console.log(`Checking for reminders at ${currentTimeStr}`);

    const habitsWithReminders = await db.collection("habits")
      .where("reminder_time", "==", currentTimeStr)
      .get();

    if (habitsWithReminders.empty) return null;

    const messages = [];
    habitsWithReminders.forEach((doc) => {
      const habit = doc.data();
      messages.push({
        token: habit.user_token, // Ideally fetched from user record or habit record
        notification: {
          title: "Forge Time! 🔨",
          body: `Time to work on your habit: ${habit.title}`,
        },
        data: {
          habitId: doc.id,
          type: "HABIT_REMINDER",
        },
      });
    });

    // Send messages via FCM (commented out as it requires valid tokens/setup)
    // await admin.messaging().sendAll(messages);
    console.log(`Triggered ${messages.length} reminders.`);
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

