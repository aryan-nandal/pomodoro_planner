const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Set emulator environment variables if they are not already set
process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';

admin.initializeApp({
  projectId: 'task-planner-c03ea'
});

const db = admin.firestore();
const auth = admin.auth();

async function clearEmulators() {
  console.log('Clearing emulators...');
  try {
    // Clear Firestore
    const firestoreUrl = `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/task-planner-c03ea/databases/(default)/documents`;
    const firestoreRes = await fetch(firestoreUrl, { method: 'DELETE' });
    if (!firestoreRes.ok) {
      throw new Error(`Failed to clear Firestore: ${firestoreRes.statusText}`);
    }

    // Clear Auth
    const authUrl = `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/emulator/v1/projects/task-planner-c03ea/accounts`;
    const authRes = await fetch(authUrl, { method: 'DELETE' });
    if (!authRes.ok) {
      throw new Error(`Failed to clear Auth: ${authRes.statusText}`);
    }

    console.log('Emulators cleared.');
  } catch (error) {
    console.error('Error clearing emulators:', error);
    throw error;
  }
}

async function seed(seedFile) {
  // Always clear the database first
  await clearEmulators();

  if (!seedFile || !fs.existsSync(seedFile)) {
    console.log(`No seed file found or provided at: ${seedFile}. Starting with an empty DB.`);
    return;
  }

  console.log(`Seeding from ${seedFile}...`);
  const data = JSON.parse(fs.readFileSync(seedFile, 'utf8'));

  // Seed Auth Users
  if (data.auth && Array.isArray(data.auth)) {
    for (const user of data.auth) {
      await auth.createUser({
        uid: user.uid,
        email: user.email,
        password: user.password
      });
      console.log(`Created Auth User: ${user.email} (${user.uid})`);
    }
  }

  // Seed Firestore Documents
  if (data.firestore && typeof data.firestore === 'object') {
    const todayIsoStr = new Date().toISOString(); // e.g., 2026-06-25T16:26:00.000Z
    const todayDateStr = todayIsoStr.split('T')[0]; // e.g., 2026-06-25

    for (const [docPath, fields] of Object.entries(data.firestore)) {
      const docData = {};
      for (const [key, val] of Object.entries(fields)) {
        if (typeof val === 'string' && val.includes('{TODAY}')) {
          // Replace {TODAY} with the actual ISO date string
          // Or if the value is JUST {TODAY}, we can format it exactly how the app expects
          // The app expects task scheduledDate to be in ISO8601 string format
          docData[key] = val.replace('{TODAY}', todayDateStr);
        } else {
          docData[key] = val;
        }
      }

      await db.doc(docPath).set(docData);
      console.log(`Seeded Firestore Document: ${docPath}`);
    }
  }

  console.log('Seeding completed successfully.');
}

const args = process.argv.slice(2);
const seedFilePath = args[0];
seed(seedFilePath).catch(err => {
  console.error('Seeding failed:', err);
  process.exit(1);
});
