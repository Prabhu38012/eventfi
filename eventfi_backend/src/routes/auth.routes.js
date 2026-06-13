const router = require('express').Router();
const { firebaseSync, me, updateProfile } = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

// POST  /api/auth/firebase  — verify Firebase ID token, return JWT + user
router.post('/firebase', firebaseSync);

// GET   /api/auth/me        — get logged-in user (protected)
router.get('/me', protect, me);

// PATCH /api/auth/profile   — update name / phone / avatar (protected)
router.patch('/profile', protect, updateProfile);

module.exports = router;
