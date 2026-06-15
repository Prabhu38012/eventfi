const Coupon = require('../models/Coupon');
const { successResponse, errorResponse } = require('../utils/response');

/// POST /api/coupons/validate  { code, amount }
const validateCoupon = async (req, res) => {
  try {
    const { code, amount } = req.body;
    if (!code) return errorResponse(res, 'Coupon code is required');

    const coupon = await Coupon.findOne({
      code:       code.trim().toUpperCase(),
      isActive:   true,
      expiryDate: { $gt: new Date() },
    });

    if (!coupon)           return errorResponse(res, 'Invalid or expired coupon code');
    if (amount < coupon.minAmount)
      return errorResponse(res, `Minimum order amount is ₹${coupon.minAmount}`);
    if (coupon.usageLimit !== null && coupon.usedCount >= coupon.usageLimit)
      return errorResponse(res, 'This coupon has reached its usage limit');

    // Calculate discount
    let discount = 0;
    if (coupon.type === 'percentage') {
      discount = (amount * coupon.value) / 100;
      if (coupon.maxDiscount) discount = Math.min(discount, coupon.maxDiscount);
    } else {
      discount = Math.min(coupon.value, amount); // can't discount more than amount
    }
    discount = Math.round(discount);

    return successResponse(res, `Coupon applied! You save ₹${discount}`, {
      discount,
      finalAmount: amount - discount,
      coupon: {
        code:        coupon.code,
        type:        coupon.type,
        value:       coupon.value,
        description: coupon.description,
      },
    });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// Admin: create sample test coupons  GET /api/coupons/seed
const seedCoupons = async (req, res) => {
  try {
    await Coupon.deleteMany({});
    await Coupon.insertMany([
      {
        code:        'WELCOME10',
        type:        'percentage',
        value:       10,
        maxDiscount: 100,
        minAmount:   200,
        expiryDate:  new Date('2027-12-31'),
        description: '10% off on your first booking (up to ₹100)',
      },
      {
        code:       'FLAT50',
        type:       'fixed',
        value:      50,
        minAmount:  300,
        expiryDate: new Date('2027-12-31'),
        description: 'Flat ₹50 off',
      },
      {
        code:        'CONCERT20',
        type:        'percentage',
        value:       20,
        maxDiscount: 200,
        minAmount:   400,
        expiryDate:  new Date('2027-12-31'),
        description: '20% off on concert bookings',
      },
    ]);
    return successResponse(res, 'Test coupons seeded', {});
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

module.exports = { validateCoupon, seedCoupons };
