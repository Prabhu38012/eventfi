const Booking       = require('../models/Booking');
const Event         = require('../models/Event');
const Coupon        = require('../models/Coupon');
const razorpay      = require('../services/razorpay.service');
const qrService     = require('../services/qr.service');
const emailService  = require('../services/email.service');
const pointsService = require('../services/points.service'); // ✅ Phase 5
const { successResponse, errorResponse } = require('../utils/response');

/// POST /api/bookings/create-order
const createOrder = async (req, res) => {
  try {
    const { eventId, seats, couponCode } = req.body;
    const event = await Event.findById(eventId);
    if (!event)                    return errorResponse(res, 'Event not found', 404);
    if (!event.isActive)           return errorResponse(res, 'Event is no longer available');
    if (event.availableSeats < seats)
      return errorResponse(res, `Only ${event.availableSeats} seats remaining`);

    let amount = event.price * seats, discount = 0;
    if (couponCode) {
      const coupon = await Coupon.findOne({
        code: couponCode.trim().toUpperCase(), isActive: true, expiryDate: { $gt: new Date() },
      });
      if (coupon) {
        discount = coupon.type === 'percentage'
          ? Math.min((amount * coupon.value) / 100, coupon.maxDiscount || Infinity)
          : Math.min(coupon.value, amount);
        discount = Math.round(discount);
      }
    }

    const finalAmount = Math.max(1, amount - discount);
    const order = await razorpay.createOrder(finalAmount);
    return successResponse(res, 'Order created', {
      orderId: order.id, amount, discount, finalAmount, currency: 'INR',
      keyId: process.env.RAZORPAY_KEY_ID,
    });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// POST /api/bookings/verify
const verifyAndBook = async (req, res) => {
  try {
    const {
      razorpayOrderId, razorpayPaymentId, razorpaySignature,
      eventId, seats, amount, discount, finalAmount, couponCode,
    } = req.body;

    if (!razorpay.verifySignature(razorpayOrderId, razorpayPaymentId, razorpaySignature))
      return errorResponse(res, 'Payment verification failed.', 400);

    const event = await Event.findById(eventId);
    if (!event || event.availableSeats < seats)
      return errorResponse(res, 'Seats no longer available', 400);

    const bookingId = 'EVT' + Math.random().toString(36).substring(2, 8).toUpperCase();
    const qrCode    = await qrService.generate(bookingId);

    const booking = await Booking.create({
      bookingId, userId: req.user._id, eventId, seats, amount,
      couponCode: couponCode || null, discount, finalAmount,
      paymentStatus: 'paid', razorpayOrderId, razorpayPaymentId, razorpaySignature, qrCode,
    });

    // Update event stats
    await Event.findByIdAndUpdate(eventId, {
      $inc: { availableSeats: -seats, bookingCount: seats },
    });

    // Update coupon usage
    if (couponCode) {
      await Coupon.findOneAndUpdate(
        { code: couponCode.toUpperCase() }, { $inc: { usedCount: 1 } }
      );
    }

    // ✅ Phase 5 — Award Gold Points via service
    const pointsEarned = await pointsService.earn(
      req.user._id,
      finalAmount,
      `Booked: ${event.title}`,
      booking._id
    );

    // Send email (non-blocking)
    emailService.sendBookingConfirmation({
      to: req.user.email, name: req.user.name,
      booking: { bookingId, seats, amount, discount, finalAmount, couponCode },
      event,
    }).catch(err => console.error('Email error:', err.message));

    return successResponse(res, 'Booking confirmed!', {
      booking: { ...booking.toObject(), event },
      pointsEarned,
    });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// GET /api/bookings/my
const getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user._id })
      .populate('eventId', 'title category city venue date time price posterUrl')
      .sort({ createdAt: -1 }).lean();
    return successResponse(res, 'Bookings fetched', { bookings });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// GET /api/bookings/:id
const getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findOne({ _id: req.params.id, userId: req.user._id })
      .populate('eventId').lean();
    if (!booking) return errorResponse(res, 'Booking not found', 404);
    return successResponse(res, 'Booking fetched', { booking });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// DELETE /api/bookings/:id
const cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findOne({ _id: req.params.id, userId: req.user._id });
    if (!booking)                              return errorResponse(res, 'Booking not found', 404);
    if (booking.paymentStatus === 'cancelled') return errorResponse(res, 'Already cancelled');
    if (booking.attended)                      return errorResponse(res, 'Cannot cancel attended booking');

    let refundId = null;
    if (booking.razorpayPaymentId && process.env.RAZORPAY_KEY_SECRET !== 'your_razorpay_secret') {
      const refund = await razorpay.refund(booking.razorpayPaymentId, booking.finalAmount);
      refundId = refund.id;
    }

    booking.paymentStatus = 'cancelled';
    booking.cancelledAt   = new Date();
    booking.refundId      = refundId;
    await booking.save();

    await Event.findByIdAndUpdate(booking.eventId, {
      $inc: { availableSeats: booking.seats, bookingCount: -booking.seats },
    });

    // Deduct earned points on cancellation
    const pointsToDeduct = Math.floor(booking.finalAmount / 100);
    if (pointsToDeduct > 0) {
      await pointsService.redeem(
        req.user._id,
        pointsToDeduct,
        `Points reversed: booking cancelled`
      );
    }

    return successResponse(res, 'Booking cancelled. Refund initiated.', { booking });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

module.exports = { createOrder, verifyAndBook, getMyBookings, getBookingById, cancelBooking };
