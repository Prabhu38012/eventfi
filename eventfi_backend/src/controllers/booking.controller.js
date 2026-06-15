const Booking   = require('../models/Booking');
const Event     = require('../models/Event');
const Coupon    = require('../models/Coupon');
const User      = require('../models/User');
const razorpay  = require('../services/razorpay.service');
const qrService = require('../services/qr.service');
const email     = require('../services/email.service');
const { successResponse, errorResponse } = require('../utils/response');

/// POST /api/bookings/create-order
/// Creates a Razorpay order before showing the payment screen
const createOrder = async (req, res) => {
  try {
    const { eventId, seats, couponCode } = req.body;

    const event = await Event.findById(eventId);
    if (!event)                    return errorResponse(res, 'Event not found', 404);
    if (!event.isActive)           return errorResponse(res, 'Event is no longer available');
    if (event.availableSeats < seats)
      return errorResponse(res, `Only ${event.availableSeats} seats remaining`);

    let amount   = event.price * seats;
    let discount = 0;

    if (couponCode) {
      const coupon = await Coupon.findOne({
        code:       couponCode.trim().toUpperCase(),
        isActive:   true,
        expiryDate: { $gt: new Date() },
      });
      if (coupon) {
        if (coupon.type === 'percentage') {
          discount = (amount * coupon.value) / 100;
          if (coupon.maxDiscount) discount = Math.min(discount, coupon.maxDiscount);
        } else {
          discount = Math.min(coupon.value, amount);
        }
        discount = Math.round(discount);
      }
    }

    const finalAmount = Math.max(1, amount - discount); // min ₹1 for Razorpay

    const order = await razorpay.createOrder(finalAmount);

    return successResponse(res, 'Order created', {
      orderId:     order.id,
      amount,
      discount,
      finalAmount,
      currency:    'INR',
      keyId:       process.env.RAZORPAY_KEY_ID,
    });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// POST /api/bookings/verify
/// Verifies Razorpay payment → creates booking → sends email
const verifyAndBook = async (req, res) => {
  try {
    const {
      razorpayOrderId, razorpayPaymentId, razorpaySignature,
      eventId, seats, amount, discount, finalAmount, couponCode,
    } = req.body;

    // 1 — Verify signature
    const valid = razorpay.verifySignature(
      razorpayOrderId, razorpayPaymentId, razorpaySignature
    );
    if (!valid) return errorResponse(res, 'Payment verification failed. Contact support.', 400);

    // 2 — Re-check seats (avoid race condition)
    const event = await Event.findById(eventId);
    if (!event || event.availableSeats < seats)
      return errorResponse(res, 'Seats no longer available', 400);

    // 3 — Generate QR code
    const bookingId = 'EVT' + Math.random().toString(36).substring(2, 8).toUpperCase();
    const qrCode    = await qrService.generate(bookingId);

    // 4 — Create booking
    const booking = await Booking.create({
      bookingId,
      userId:            req.user._id,
      eventId,
      seats,
      amount,
      couponCode:        couponCode || null,
      discount,
      finalAmount,
      paymentStatus:     'paid',
      razorpayOrderId,
      razorpayPaymentId,
      razorpaySignature,
      qrCode,
    });

    // 5 — Update event
    await Event.findByIdAndUpdate(eventId, {
      $inc: { availableSeats: -seats, bookingCount: seats },
    });

    // 6 — Update coupon usage
    if (couponCode) {
      await Coupon.findOneAndUpdate(
        { code: couponCode.toUpperCase() },
        { $inc: { usedCount: 1 } }
      );
    }

    // 7 — Award Gold Points (₹100 = 1 point)
    const pointsEarned = Math.floor(finalAmount / 100);
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { points: pointsEarned },
    });

    // 8 — Send confirmation email (non-blocking)
    email.sendBookingConfirmation({
      to:      req.user.email,
      name:    req.user.name,
      booking: { bookingId, seats, amount, discount, finalAmount, couponCode },
      event,
    }).catch((err) => console.error('Email error:', err.message));

    return successResponse(res, 'Booking confirmed!', {
      booking: { ...booking.toObject(), event },
      pointsEarned,
    });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// GET /api/bookings/my
const getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user._id })
      .populate('eventId', 'title category city venue date time price posterUrl')
      .sort({ createdAt: -1 })
      .lean();
    return successResponse(res, 'Bookings fetched', { bookings });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// GET /api/bookings/:id
const getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findOne({
      _id:    req.params.id,
      userId: req.user._id,
    }).populate('eventId').lean();
    if (!booking) return errorResponse(res, 'Booking not found', 404);
    return successResponse(res, 'Booking fetched', { booking });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// DELETE /api/bookings/:id  — cancel booking + refund
const cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findOne({
      _id:    req.params.id,
      userId: req.user._id,
    });
    if (!booking)                            return errorResponse(res, 'Booking not found', 404);
    if (booking.paymentStatus === 'cancelled') return errorResponse(res, 'Already cancelled');
    if (booking.attended)                    return errorResponse(res, 'Cannot cancel attended booking');

    // Initiate Razorpay refund
    let refundId = null;
    if (booking.razorpayPaymentId && process.env.RAZORPAY_KEY_SECRET !== 'your_razorpay_secret') {
      const refund = await razorpay.refund(booking.razorpayPaymentId, booking.finalAmount);
      refundId = refund.id;
    }

    // Update booking
    booking.paymentStatus = 'cancelled';
    booking.cancelledAt   = new Date();
    booking.refundId      = refundId;
    await booking.save();

    // Restore seats
    await Event.findByIdAndUpdate(booking.eventId, {
      $inc: { availableSeats: booking.seats, bookingCount: -booking.seats },
    });

    // Deduct gold points
    const pointsEarned = Math.floor(booking.finalAmount / 100);
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { points: -pointsEarned },
    });

    return successResponse(res, 'Booking cancelled. Refund initiated.', { booking });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

module.exports = { createOrder, verifyAndBook, getMyBookings, getBookingById, cancelBooking };
