const Notification = require('../models/Notification');
const User         = require('../models/User');
const admin        = require('../config/firebase');
const { successResponse, errorResponse } = require('../utils/response');

/// GET /api/notifications
const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();
    const unreadCount = notifications.filter(n => !n.isRead).length;
    return successResponse(res, 'Notifications fetched', { notifications, unreadCount });
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// PUT /api/notifications/:id/read
const markRead = async (req, res) => {
  try {
    await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { $set: { isRead: true } }
    );
    return successResponse(res, 'Marked as read');
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// PUT /api/notifications/read-all
const markAllRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user._id, isRead: false },
      { $set: { isRead: true } }
    );
    return successResponse(res, 'All notifications marked as read');
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// POST /api/notifications/register-token
const registerToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) return errorResponse(res, 'FCM token is required');
    await User.findByIdAndUpdate(req.user._id, { $set: { fcmToken } });
    return successResponse(res, 'FCM token registered');
  } catch (err) { return errorResponse(res, err.message, 500); }
};

/// Utility: send push notification + store in DB
/// Called from other controllers (booking, events, etc.)
const sendToUser = async (userId, title, body, type = 'system', data = {}) => {
  try {
    await Notification.create({ userId, title, body, type, data });

    const user = await User.findById(userId).select('fcmToken').lean();
    if (user?.fcmToken) {
      await admin.messaging().send({
        token:        user.fcmToken,
        notification: { title, body },
        data:         Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)])
        ),
      }).catch(e => console.error('FCM push error:', e.message));
    }
  } catch (err) {
    console.error('sendToUser error:', err.message);
  }
};

module.exports = { getNotifications, markRead, markAllRead, registerToken, sendToUser };
