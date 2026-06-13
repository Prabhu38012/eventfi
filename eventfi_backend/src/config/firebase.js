const admin = require('firebase-admin');

if (!admin.apps.length) {
  const isPlaceholder = !process.env.FIREBASE_PRIVATE_KEY ||
                        process.env.FIREBASE_PRIVATE_KEY.includes('YOUR_KEY_HERE') ||
                        process.env.FIREBASE_PROJECT_ID === 'your-firebase-project-id';

  if (isPlaceholder) {
    console.warn('⚠️  [Firebase] Firebase Admin SDK is not configured. Firebase auth sync routes will fail.');
  } else {
    try {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId:   process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          // .env stores \n as literal \\n — replace back to real newlines
          privateKey:  process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
      });
      console.log('🔥 [Firebase] Firebase Admin SDK initialized successfully');
    } catch (error) {
      console.error('❌ [Firebase] Failed to initialize Firebase Admin SDK:', error.message);
    }
  }
}

module.exports = admin;
