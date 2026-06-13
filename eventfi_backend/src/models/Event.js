const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema(
  {
    title:       { type: String, required: true, trim: true },
    category: {
      type:     String,
      required: true,
      enum:     ['theatre', 'concert', 'standup', 'dance', 'themePark'],
    },
    description:    { type: String, required: true },
    city:           { type: String, required: true, trim: true },
    district:       { type: String, required: true, trim: true },
    venue:          { type: String, required: true, trim: true },
    posterUrl:      { type: String, default: null },
    images:         [{ type: String }],
    date:           { type: Date, required: true },
    time:           { type: String, required: true },
    price:          { type: Number, required: true, min: 0 },
    totalSeats:     { type: Number, required: true, min: 1 },
    availableSeats: { type: Number, required: true, min: 0 },
    latitude:       { type: Number, default: null },
    longitude:      { type: Number, default: null },
    organizerName:  { type: String, default: '' },
    organizerPhone: { type: String, default: '' },
    bookingCount:   { type: Number, default: 0, min: 0 },
    isActive:       { type: Boolean, default: true },
  },
  { timestamps: true }
);

// Indexes for fast queries
eventSchema.index({ category: 1, isActive: 1, date: 1 });
eventSchema.index({ bookingCount: -1, isActive: 1 });
eventSchema.index({ district: 1, isActive: 1 });
eventSchema.index({ title: 'text', venue: 'text', city: 'text' });

module.exports = mongoose.model('Event', eventSchema);
