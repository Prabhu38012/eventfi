const mongoose = require('mongoose');

const pointsSchema = new mongoose.Schema(
  {
    userId: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'User',
      required: true,
      index:    true,
    },
    amount:  { type: Number, required: true }, // +ve = earn, -ve = redeem
    type: {
      type: String,
      required: true,
      enum: ['earn', 'redeem', 'referral', 'bonus', 'expire'],
    },
    description: { type: String, default: '' },
    bookingId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', default: null },
    expiresAt:   { type: Date, default: null },
    isExpired:   { type: Boolean, default: false },
  },
  { timestamps: true }
);

pointsSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Points', pointsSchema);
