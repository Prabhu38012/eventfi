const express = require('express');
const cors    = require('cors');
require('dotenv').config();

const app = express();

app.use(cors({ origin: '*', methods: ['GET','POST','PUT','PATCH','DELETE'], allowedHeaders: ['Content-Type','Authorization'] }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => res.json({ status: 'ok', app: 'EventFi API', version: '1.0.0' }));

// ─── Routes ──────────────────────────────────────────────────
app.use('/api/auth',          require('./routes/auth.routes'));
app.use('/api/events',        require('./routes/event.routes'));
app.use('/api/bookings',      require('./routes/booking.routes'));
app.use('/api/coupons',       require('./routes/coupon.routes'));
app.use('/api/points',        require('./routes/points.routes'));
app.use('/api/wishlist',      require('./routes/wishlist.routes'));
app.use('/api/reviews',       require('./routes/review.routes'));
app.use('/api/notifications', require('./routes/notification.routes'));
app.use('/api/admin',         require('./routes/admin.routes'));   // ✅ Phase 7

app.use((req, res) => res.status(404).json({ success: false, message: 'Route not found' }));
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: err.message });
});

module.exports = app;
