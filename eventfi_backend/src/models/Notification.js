const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title:  { type: String, required: true },
    body:   { type: String, required: true },
    type: {
      type:    String,
      enum:    ['booking', 'event', 'offer', 'points', 'system'],
      default: 'system',
    },
    data:   { type: Object,  default: {} },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true }
);

notificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
