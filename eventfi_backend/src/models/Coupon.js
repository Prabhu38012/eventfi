const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema(
  {
    code:       { type: String,  required: true, unique: true, uppercase: true, trim: true },
    type:       { type: String,  required: true, enum: ['percentage', 'fixed'] },
    value:      { type: Number,  required: true, min: 0 },      // % or ₹ amount
    maxDiscount: { type: Number, default: null },                // cap for percentage
    minAmount:  { type: Number,  default: 0 },                  // minimum cart value
    expiryDate: { type: Date,    required: true },
    usageLimit: { type: Number,  default: null },                // null = unlimited
    usedCount:  { type: Number,  default: 0 },
    isActive:   { type: Boolean, default: true },
    description: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Coupon', couponSchema);
