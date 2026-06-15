const express = require('express');
const router  = express.Router();
const { validateCoupon, seedCoupons } = require('../controllers/coupon.controller');
const { protect } = require('../middleware/auth.middleware');

router.post('/validate', protect, validateCoupon);
router.get('/seed',      seedCoupons);  // call once to create test coupons

module.exports = router;
