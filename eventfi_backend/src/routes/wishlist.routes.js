const express = require('express');
const router  = express.Router();
const { getWishlist, getWishlistIds, toggleWishlist } = require('../controllers/wishlist.controller');
const { protect } = require('../middleware/auth.middleware');

router.get('/',          protect, getWishlist);
router.get('/ids',       protect, getWishlistIds);
router.post('/:eventId', protect, toggleWishlist);

module.exports = router;
