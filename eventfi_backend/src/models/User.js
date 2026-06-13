const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    firebaseUid:  { type: String, required: true, unique: true, index: true },
    name:         { type: String, required: true, trim: true },
    email:        { type: String, sparse: true, lowercase: true, trim: true },
    phone:        { type: String, sparse: true },
    avatar:       { type: String },
    role:         { type: String, enum: ['user', 'admin'], default: 'user' },
    points:       { type: Number, default: 0, min: 0 },
    referralCode: { type: String, unique: true, sparse: true },
    referredBy:   { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    fcmToken:     { type: String },
    isActive:     { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
