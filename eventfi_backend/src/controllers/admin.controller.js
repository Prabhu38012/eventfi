const Event   = require('../models/Event');
const Booking = require('../models/Booking');
const User    = require('../models/User');
const Coupon  = require('../models/Coupon');

const ok  = (res, msg, data = {}, code = 200) =>
  res.status(code).json({ success: true,  message: msg, ...data });
const err = (res, msg, code = 400) =>
  res.status(code).json({ success: false, message: msg });

// ── Dashboard ─────────────────────────────────────────────────
/// GET /api/admin/stats
const getDashboardStats = async (req, res) => {
  try {
    const [totalBookings, revenueAgg, totalEvents, totalUsers, recentBookings] =
      await Promise.all([
        Booking.countDocuments({ paymentStatus: 'paid' }),
        Booking.aggregate([
          { $match: { paymentStatus: 'paid' } },
          { $group: { _id: null, total: { $sum: '$finalAmount' } } },
        ]),
        Event.countDocuments({ isActive: true }),
        User.countDocuments({ role: 'user' }),
        Booking.find({ paymentStatus: 'paid' })
          .populate('userId',  'name email')
          .populate('eventId', 'title category')
          .sort({ createdAt: -1 })
          .limit(10)
          .lean(),
      ]);

    return ok(res, 'Stats fetched', {
      stats: {
        totalBookings,
        totalRevenue: revenueAgg[0]?.total || 0,
        totalEvents,
        totalUsers,
      },
      recentBookings,
    });
  } catch (e) { return err(res, e.message, 500); }
};

// ── Events CRUD ───────────────────────────────────────────────
/// GET /api/admin/events
const getAllEvents = async (req, res) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 }).lean();
    return ok(res, 'Events fetched', { events });
  } catch (e) { return err(res, e.message, 500); }
};

/// POST /api/admin/events
const createEvent = async (req, res) => {
  try {
    const event = await Event.create(req.body);
    return ok(res, 'Event created!', { event }, 201);
  } catch (e) { return err(res, e.message, 500); }
};

/// PUT /api/admin/events/:id
const updateEvent = async (req, res) => {
  try {
    const event = await Event.findByIdAndUpdate(
      req.params.id, req.body, { new: true, runValidators: true }
    );
    if (!event) return err(res, 'Event not found', 404);
    return ok(res, 'Event updated!', { event });
  } catch (e) { return err(res, e.message, 500); }
};

/// DELETE /api/admin/events/:id
const deleteEvent = async (req, res) => {
  try {
    const event = await Event.findByIdAndDelete(req.params.id);
    if (!event) return err(res, 'Event not found', 404);
    return ok(res, 'Event deleted');
  } catch (e) { return err(res, e.message, 500); }
};

// ── Bookings ──────────────────────────────────────────────────
/// GET /api/admin/bookings?status=paid&page=1
const getAllBookings = async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const filter = status ? { paymentStatus: status } : {};

    const [bookings, total] = await Promise.all([
      Booking.find(filter)
        .populate('userId',  'name email')
        .populate('eventId', 'title category city')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(Number(limit))
        .lean(),
      Booking.countDocuments(filter),
    ]);

    return ok(res, 'Bookings fetched', { bookings, total });
  } catch (e) { return err(res, e.message, 500); }
};

/// GET /api/admin/bookings/scan/:bookingId — QR scanner lookup
const scanBooking = async (req, res) => {
  try {
    const booking = await Booking.findOne({ bookingId: req.params.bookingId })
      .populate('userId',  'name email')
      .populate('eventId', 'title category venue city date time');
    if (!booking)                            return err(res, 'Invalid QR — booking not found', 404);
    if (booking.paymentStatus !== 'paid')    return err(res, 'Booking not paid');
    return ok(res, 'Booking found', { booking });
  } catch (e) { return err(res, e.message, 500); }
};

/// PUT /api/admin/bookings/:id/attend — mark attendee at gate
const markAttended = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('userId',  'name email')
      .populate('eventId', 'title');
    if (!booking)                         return err(res, 'Booking not found', 404);
    if (booking.paymentStatus !== 'paid') return err(res, 'Booking not paid');
    if (booking.attended)                 return err(res, 'Already scanned in');

    booking.attended = true;
    await booking.save();
    return ok(res, '✅ Attendee checked in!', { booking });
  } catch (e) { return err(res, e.message, 500); }
};

// ── Coupons ───────────────────────────────────────────────────
/// GET /api/admin/coupons
const getAllCoupons = async (req, res) => {
  try {
    const coupons = await Coupon.find().sort({ createdAt: -1 }).lean();
    return ok(res, 'Coupons fetched', { coupons });
  } catch (e) { return err(res, e.message, 500); }
};

/// POST /api/admin/coupons
const createCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.create(req.body);
    return ok(res, 'Coupon created!', { coupon }, 201);
  } catch (e) { return err(res, e.message, 500); }
};

/// PUT /api/admin/coupons/:id/toggle
const toggleCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.findById(req.params.id);
    if (!coupon) return err(res, 'Coupon not found', 404);
    coupon.isActive = !coupon.isActive;
    await coupon.save();
    return ok(res, `Coupon ${coupon.isActive ? 'enabled' : 'disabled'}`, { coupon });
  } catch (e) { return err(res, e.message, 500); }
};

/// DELETE /api/admin/coupons/:id
const deleteCoupon = async (req, res) => {
  try {
    await Coupon.findByIdAndDelete(req.params.id);
    return ok(res, 'Coupon deleted');
  } catch (e) { return err(res, e.message, 500); }
};

module.exports = {
  getDashboardStats,
  getAllEvents, createEvent, updateEvent, deleteEvent,
  getAllBookings, scanBooking, markAttended,
  getAllCoupons, createCoupon, toggleCoupon, deleteCoupon,
};
