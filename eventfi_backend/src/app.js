const express = require('express');
const cors    = require('cors');
require('dotenv').config();

const app = express();

app.use(cors({ origin: '*', methods: ['GET','POST','PUT','PATCH','DELETE'], allowedHeaders: ['Content-Type','Authorization'] }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => res.json({ status: 'ok', app: 'EventFi API', version: '1.0.0' }));

// ─── Routes ──────────────────────────────────────────────────
app.use('/api/auth',          require('./routes/auth.routes'));         // ✅ Phase 1
app.use('/api/events',        require('./routes/event.routes'));        // ✅ Phase 2
app.use('/api/bookings',      require('./routes/booking.routes'));      // ✅ Phase 4
app.use('/api/coupons',       require('./routes/coupon.routes'));       // ✅ Phase 4
app.use('/api/points',        require('./routes/points.routes'));       // ✅ Phase 5
app.use('/api/wishlist',      require('./routes/wishlist.routes'));     // ✅ Phase 6
app.use('/api/reviews',       require('./routes/review.routes'));       // ✅ Phase 6
app.use('/api/notifications', require('./routes/notification.routes'));// ✅ Phase 6
// Phase 7:  app.use('/api/admin', require('./routes/admin.routes'));

app.use((req, res) => res.status(404).json({ success: false, message: 'Route not found' }));
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ success: false, message: err.message || 'Internal Server Error' });
});

module.exports = app;
