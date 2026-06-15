const express = require('express');
const router  = express.Router();
const { getNotifications, markRead, markAllRead, registerToken } =
  require('../controllers/notification.controller');
const { protect } = require('../middleware/auth.middleware');

router.get('/',                protect, getNotifications);
router.put('/read-all',        protect, markAllRead);
router.put('/:id/read',        protect, markRead);
router.post('/register-token', protect, registerToken);

module.exports = router;
