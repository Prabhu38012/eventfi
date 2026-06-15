const User   = require('../models/User');
const Points = require('../models/Points');

/// Earn points — ₹100 = 1 Gold Point, 90-day expiry
const earn = async (userId, amountPaid, description, bookingId = null) => {
  const pts = Math.floor(amountPaid / 100);
  if (pts <= 0) return 0;

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 90);

  await Promise.all([
    User.findByIdAndUpdate(userId, { $inc: { points: pts } }),
    Points.create({ userId, amount: pts, type: 'earn', description, bookingId, expiresAt }),
  ]);

  return pts;
};

/// Redeem points — deduct from user balance and log
const redeem = async (userId, pts, description) => {
  await Promise.all([
    User.findByIdAndUpdate(userId, { $inc: { points: -pts } }),
    Points.create({ userId, amount: -pts, type: 'redeem', description }),
  ]);
};

/// Award referral bonus
const awardReferralBonus = async (referrerId, newUserId) => {
  await Promise.all([
    // Referrer gets 10 points
    User.findByIdAndUpdate(referrerId, { $inc: { points: 10 } }),
    Points.create({
      userId:      referrerId,
      amount:      10,
      type:        'referral',
      description: 'Referral bonus — friend joined EventFi',
    }),
    // New user gets 5 points
    User.findByIdAndUpdate(newUserId, { $inc: { points: 5 } }),
    Points.create({
      userId:      newUserId,
      amount:      5,
      type:        'bonus',
      description: 'Welcome bonus — joined via referral',
    }),
  ]);
};

module.exports = { earn, redeem, awardReferralBonus };
