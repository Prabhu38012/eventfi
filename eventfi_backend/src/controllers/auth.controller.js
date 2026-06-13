const jwt   = require('jsonwebtoken');
const User  = require('../models/User');
const admin = require('../config/firebase');
const { success, error } = require('../utils/response');

// ─────────────────────────────────────────────────────────────
//  POST /api/auth/firebase
//  Flutter sends Firebase ID token → verify → create/get user → return JWT
// ─────────────────────────────────────────────────────────────
exports.firebaseSync = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json(error('ID token is required'));

    // 1. Verify Firebase token
    const decoded = await admin.auth().verifyIdToken(idToken);
    const { uid, email, name, picture, phone_number } = decoded;

    // 2. Find or create user in MongoDB
    let user = await User.findOne({ firebaseUid: uid });

    if (!user) {
      // First time — create user
      const displayName = name || email?.split('@')[0] || 'EventFi User';
      user = await User.create({
        firebaseUid:  uid,
        name:         displayName,
        email:        email   || null,
        phone:        phone_number || null,
        avatar:       picture || null,
        referralCode: uid.slice(0, 8).toUpperCase(),
      });
    }

    // 3. Issue our own JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return res.status(200).json(success({ token, user }));
  } catch (err) {
    console.error('firebaseSync error:', err.message);
    return res.status(401).json(error('Invalid or expired Firebase token'));
  }
};

// ─────────────────────────────────────────────────────────────
//  GET /api/auth/me   (protected)
// ─────────────────────────────────────────────────────────────
exports.me = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-firebaseUid -__v');
    if (!user) return res.status(404).json(error('User not found'));
    return res.json(success(user));
  } catch (err) {
    return res.status(500).json(error('Server error'));
  }
};

// ─────────────────────────────────────────────────────────────
//  PATCH /api/auth/profile   (protected)
// ─────────────────────────────────────────────────────────────
exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, avatar } = req.body;

    const allowed = {};
    if (name)   allowed.name   = name.trim();
    if (phone)  allowed.phone  = phone.trim();
    if (avatar) allowed.avatar = avatar;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      allowed,
      { new: true, select: '-firebaseUid -__v' }
    );

    return res.json(success(user, 'Profile updated'));
  } catch (err) {
    return res.status(500).json(error('Server error'));
  }
};
