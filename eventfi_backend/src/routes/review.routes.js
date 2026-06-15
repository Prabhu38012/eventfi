const express = require('express');
const router  = express.Router();
const { getEventReviews, addReview, deleteReview } = require('../controllers/review.controller');
const { protect } = require('../middleware/auth.middleware');

router.get('/event/:eventId', getEventReviews);          // public
router.post('/',              protect, addReview);
router.delete('/:id',         protect, deleteReview);

module.exports = router;
