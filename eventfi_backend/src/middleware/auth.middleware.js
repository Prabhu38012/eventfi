const admin = require('../config/firebase');
const User  = require('../models/User');

// ─────────────────────────────────────────────────────────────
//  Auth Middleware
//
//  1. Verifies Firebase ID token via Firebase Admin SDK
//  2. Finds user in MongoDB by firebaseUid or email
//  3. If user not in MongoDB yet (e.g. /auth/sync was never called),
//     auto-creates them so they can use the app immediately.
// ─────────────────────────────────────────────────────────────

const protect = async (req, res, next) => {
  try {
    const header = req.headers.authorization;

    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'No auth token provided' });
    }

    const token = header.split('Bearer ')[1];
    if (!token || token === 'null' || token === 'undefined') {
      return res.status(401).json({ success: false, message: 'Invalid auth token' });
    }

    // ── Step 1: Verify Firebase ID token ─────────────────────
    let decoded;
    try {
      decoded = await admin.auth().verifyIdToken(token);
    } catch (firebaseErr) {
      console.error('[Auth] Firebase verify failed:', firebaseErr.code);
      if (firebaseErr.code === 'auth/id-token-expired') {
        return res.status(401).json({ success: false, message: 'Token expired. Please refresh.' });
      }
      return res.status(401).json({ success: false, message: 'Invalid Firebase token' });
    }

    // ── Step 2: Find user in MongoDB ─────────────────────────
    let user = await User.findOne({
      $or: [
        { firebaseUid: decoded.uid   },
        { uid:         decoded.uid   },
        { email:       decoded.email },
      ],
    }).select('-__v');

    // ── Step 3: Auto-create if not found ─────────────────────
    // This handles the case where /auth/sync was never called
    // (e.g. backend was down during signup, or user signed up
    // via Firebase console). Firebase already verified them so
    // it's safe to create their MongoDB record now.
    if (!user) {
      console.log(`[Auth] Auto-creating MongoDB record for: ${decoded.email}`);
      try {
        user = await User.create({
          firebaseUid: decoded.uid,
          email:       decoded.email  || '',
          name:        decoded.name   || (decoded.email
                         ? decoded.email.split('@')[0]
                         : 'EventFi User'),
          avatar:      decoded.picture || '',
          role:        'user',
          points:      0,
          wishlist:    [],
        });
        console.log(`[Auth] ✅ User created: ${user.email}`);
      } catch (createErr) {
        // Race condition — another request may have created the user
        user = await User.findOne({ firebaseUid: decoded.uid });
        if (!user) {
          console.error('[Auth] Failed to create user:', createErr.message);
          return res.status(500).json({ success: false, message: 'Failed to create account' });
        }
      }
    }

    // Backfill firebaseUid if the user was found only by email
    if (!user.firebaseUid) {
      user.firebaseUid = decoded.uid;
      await user.save().catch(() => {});
    }

    req.user = user;
    next();
  } catch (err) {
    console.error('[Auth] Middleware error:', err.message);
    return res.status(500).json({ success: false, message: 'Authentication error' });
  }
};

module.exports = { protect };