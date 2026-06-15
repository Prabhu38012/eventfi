const User         = require('../models/User');
const Points       = require('../models/Points');
const Coupon       = require('../models/Coupon');
const pointsService = require('../services/points.service');
const { successResponse, errorResponse } = require('../utils/response');

// ─── Rewards Catalog (admin-editable in Phase 7) ─────────────
const REWARDS = [
  {
    id:          'r1',
    emoji:       '🎟️',
    name:        '₹50 Off Coupon',
    description: 'Get ₹50 discount on your next booking',
    points:      25,
    couponValue: 50,
    couponType:  'fixed',
  },
  {
    id:          'r2',
    emoji:       '💰',
    name:        '₹100 Off Coupon',
    description: 'Get ₹100 discount on your next booking',
    points:      50,
    couponValue: 100,
    couponType:  'fixed',
  },
  {
    id:          'r3',
    emoji:       '🎫',
    name:        '₹200 Off Coupon',
    description: 'Get ₹200 discount on your next booking',
    points:      100,
    couponValue: 200,
    couponType:  'fixed',
  },
  {
    id:          'r4',
    emoji:       '👑',
    name:        'Free Event Pass',
    description: 'Free entry to any event priced up to ₹500',
    points:      200,
    couponValue: 500,
    couponType:  'fixed',
  },
];

/// GET /api/points/balance
const getBalance = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('points').lean();
    return successResponse(res, 'Balance fetched', { balance: user.points || 0 });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// GET /api/points/history
const getHistory = async (req, res) => {
  try {
    const history = await Points.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();
    return successResponse(res, 'History fetched', { history });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

/// GET /api/points/rewards
const getRewards = async (req, res) => {
  return successResponse(res, 'Rewards fetched', { rewards: REWARDS });
};

/// POST /api/points/redeem  { rewardId }
const redeemReward = async (req, res) => {
  try {
    const { rewardId } = req.body;
    const reward = REWARDS.find(r => r.id === rewardId);
    if (!reward) return errorResponse(res, 'Reward not found', 404);

    const user = await User.findById(req.user._id);
    if ((user.points || 0) < reward.points) {
      return errorResponse(
        res,
        `You need ${reward.points} pts. You have ${user.points || 0} pts.`
      );
    }

    // Deduct points
    await pointsService.redeem(
      req.user._id,
      reward.points,
      `Redeemed: ${reward.name}`
    );

    // Create a unique coupon valid for 30 days
    const couponCode =
      'RWRD' + Math.random().toString(36).substring(2, 7).toUpperCase();

    await Coupon.create({
      code:        couponCode,
      type:        reward.couponType,
      value:       reward.couponValue,
      minAmount:   0,
      expiryDate:  new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      usageLimit:  1,
      usedCount:   0,
      isActive:    true,
      description: `Reward redemption: ${reward.name}`,
    });

    const updatedUser = await User.findById(req.user._id).select('points');

    return successResponse(res, `${reward.name} redeemed!`, {
      couponCode,
      pointsUsed:      reward.points,
      remainingPoints: updatedUser.points || 0,
    });
  } catch (err) {
    return errorResponse(res, err.message, 500);
  }
};

module.exports = { getBalance, getHistory, getRewards, redeemReward };
