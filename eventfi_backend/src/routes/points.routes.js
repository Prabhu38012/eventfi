const express = require('express');
const router  = express.Router();
const { getBalance, getHistory, getRewards, redeemReward } =
  require('../controllers/points.controller');
const { protect } = require('../middleware/auth.middleware');

router.get('/balance',  protect, getBalance);
router.get('/history',  protect, getHistory);
router.get('/rewards',  protect, getRewards);
router.post('/redeem',  protect, redeemReward);

module.exports = router;
