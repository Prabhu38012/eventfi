const User = require('../models/User');
const { successResponse, errorResponse } = require('../utils/response');

/// GET /api/wishlist  — full event objects
const getWishlist = async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .populate({
        path:   'wishlist',
        select: 'title category city venue date time price posterUrl availableSeats bookingCount',
      })
      .select('wishlist');
    return successResponse(res, 'Wishlist fetched', { events: user.wishlist || [] });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// GET /api/wishlist/ids  — just the event IDs (for quick lookup)
const getWishlistIds = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('wishlist');
    return successResponse(res, 'IDs fetched', { ids: (user.wishlist || []).map(String) });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// POST /api/wishlist/:eventId  — toggle save/remove
const toggleWishlist = async (req, res) => {
  try {
    const { eventId } = req.params;
    const user = await User.findById(req.user._id);
    const idx  = user.wishlist.findIndex(id => id.toString() === eventId);
    let added;
    if (idx === -1) { user.wishlist.push(eventId); added = true; }
    else            { user.wishlist.splice(idx, 1); added = false; }
    await user.save();
    return successResponse(res, added ? 'Added to wishlist' : 'Removed from wishlist', { added });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

module.exports = { getWishlist, getWishlistIds, toggleWishlist };
