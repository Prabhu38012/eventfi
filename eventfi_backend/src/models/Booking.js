const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    bookingId: {
      type:    String,
      unique:  true,
      default: () => 'EVT' + Math.random().toString(36).substring(2, 8).toUpperCase(),
    },
    userId:   { type: mongoose.Schema.Types.ObjectId, ref: 'User',  required: true },
    eventId:  { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
    seats:    { type: Number, required: true, min: 1, max: 10 },
    amount:       { type: Number, required: true },  // original price × seats
    couponCode:   { type: String,  default: null },
    discount:     { type: Number,  default: 0 },
    finalAmount:  { type: Number,  required: true }, // after discount
    paymentStatus: {
      type:    String,
      enum:    ['pending', 'paid', 'cancelled', 'refunded'],
      default: 'pending',
    },
    razorpayOrderId:   { type: String, default: null },
    razorpayPaymentId: { type: String, default: null },
    razorpaySignature: { type: String, default: null },
    qrCode:    { type: String,  default: null }, // base64 data URL
    attended:  { type: Boolean, default: false },
    cancelledAt: { type: Date,  default: null },
    refundId:    { type: String, default: null },
  },
  { timestamps: true }
);

bookingSchema.index({ userId: 1, createdAt: -1 });
bookingSchema.index({ eventId: 1 });
bookingSchema.index({ razorpayOrderId: 1 });

module.exports = mongoose.model('Booking', bookingSchema);
