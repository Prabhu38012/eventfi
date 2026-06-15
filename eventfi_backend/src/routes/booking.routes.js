const express = require('express');
const router  = express.Router();
const { createOrder, verifyAndBook, getMyBookings, getBookingById, cancelBooking } =
  require('../controllers/booking.controller');
const { protect } = require('../middleware/auth.middleware');

router.post('/create-order', protect, createOrder);
router.post('/verify',       protect, verifyAndBook);
router.get('/my',            protect, getMyBookings);
router.get('/:id',           protect, getBookingById);
router.delete('/:id',        protect, cancelBooking);

module.exports = router;
