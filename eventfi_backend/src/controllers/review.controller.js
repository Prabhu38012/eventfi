const Review  = require('../models/Review');
const Booking = require('../models/Booking');
const { successResponse, errorResponse } = require('../utils/response');

/// GET /api/reviews/event/:eventId
const getEventReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ eventId: req.params.eventId })
      .populate('userId', 'name avatar')
      .sort({ createdAt: -1 })
      .lean();

    const avgRating = reviews.length > 0
      ? Math.round((reviews.reduce((s, r) => s + r.rating, 0) / reviews.length) * 10) / 10
      : 0;

    return successResponse(res, 'Reviews fetched', {
      reviews,
      avgRating,
      totalReviews: reviews.length,
    });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// POST /api/reviews
const addReview = async (req, res) => {
  try {
    const { eventId, rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5)
      return errorResponse(res, 'Rating must be between 1 and 5');

    // One review per user per event
    const exists = await Review.findOne({ userId: req.user._id, eventId });
    if (exists) return errorResponse(res, 'You have already reviewed this event');

    // Must have a paid booking
    const booking = await Booking.findOne({
      userId: req.user._id, eventId, paymentStatus: 'paid',
    });
    if (!booking)
      return errorResponse(res, 'You can only review events you have booked');

    const review   = await Review.create({
      userId: req.user._id, eventId, rating,
      comment: comment?.trim() || '',
    });
    const populated = await Review.findById(review._id).populate('userId', 'name avatar');

    return successResponse(res, 'Review submitted! Thank you.', { review: populated }, 201);
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// DELETE /api/reviews/:id
const deleteReview = async (req, res) => {
  try {
    const review = await Review.findOne({ _id: req.params.id, userId: req.user._id });
    if (!review) return errorResponse(res, 'Review not found', 404);
    await review.deleteOne();
    return successResponse(res, 'Review deleted');
  } catch (err) { return errorResponse(res, err.message, 500); }
};

module.exports = { getEventReviews, addReview, deleteReview };
