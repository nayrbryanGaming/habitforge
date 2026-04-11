const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Scheduled function to run every day at midnight (server time)
// It cleans up old unused data or triggers daily calculations
exports.dailyCleanup = functions.pubsub.schedule("0 0 * * *")
  .timeZone("America/New_York")
  .onRun(async (context) => {
    console.log("Running daily cleanup task");
    // Placeholder for actual cleanup logic
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

  await batch.commit();
  console.log(`Cleanup complete for user: ${uid}`);
  return null;
});
