const express    = require('express');
const router     = express.Router();
const { protect }   = require('../middleware/auth.middleware');
const { adminOnly } = require('../middleware/admin.middleware');
const {
  getDashboardStats,
  getAllEvents, createEvent, updateEvent, deleteEvent,
  getAllBookings, scanBooking, markAttended,
  getAllCoupons, createCoupon, toggleCoupon, deleteCoupon,
} = require('../controllers/admin.controller');

// All admin routes require: Firebase token + admin role
router.use(protect);
router.use(adminOnly);

// ── Dashboard ─────────────────────────────────────────────────
router.get('/stats', getDashboardStats);

// ── Events ────────────────────────────────────────────────────
router.get   ('/events',     getAllEvents);
router.post  ('/events',     createEvent);
router.put   ('/events/:id', updateEvent);
router.delete('/events/:id', deleteEvent);

// ── Bookings ──────────────────────────────────────────────────
router.get('/bookings',                 getAllBookings);
router.get('/bookings/scan/:bookingId', scanBooking);
router.put('/bookings/:id/attend',      markAttended);

// ── Coupons ───────────────────────────────────────────────────
router.get   ('/coupons',            getAllCoupons);
router.post  ('/coupons',            createCoupon);
router.put   ('/coupons/:id/toggle', toggleCoupon);
router.delete('/coupons/:id',        deleteCoupon);

module.exports = router;
