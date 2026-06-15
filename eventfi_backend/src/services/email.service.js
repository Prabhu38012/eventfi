const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const sendBookingConfirmation = async ({ to, name, booking, event }) => {
  const subject = `Booking Confirmed — ${event.title}`;

  const html = `
  <!DOCTYPE html>
  <html>
  <body style="background:#F7F4EE;font-family:Arial,sans-serif;padding:20px">
    <div style="max-width:520px;margin:0 auto;background:#1C1917;border-radius:14px;overflow:hidden">
      
      <!-- Header -->
      <div style="background:#FF6B35;padding:24px;text-align:center">
        <h1 style="color:#1C1917;margin:0;font-size:28px;letter-spacing:1px">EventFi</h1>
        <p style="color:#1C1917;margin:6px 0 0;font-size:13px">Tamil Nadu's Live Event Platform</p>
      </div>

      <!-- Body -->
      <div style="padding:28px">
        <h2 style="color:#F7F4EE;margin:0 0 6px">🎉 Booking Confirmed!</h2>
        <p style="color:#9A8F87;margin:0 0 24px">Hello ${name}, your ticket is ready.</p>

        <!-- Booking ID -->
        <div style="background:#262220;border-radius:8px;padding:16px;margin-bottom:16px;text-align:center">
          <p style="color:#9A8F87;margin:0 0 4px;font-size:12px;letter-spacing:1px">BOOKING ID</p>
          <p style="color:#FF6B35;margin:0;font-size:22px;font-weight:bold;letter-spacing:2px">${booking.bookingId}</p>
        </div>

        <!-- Event details -->
        <div style="background:#262220;border-radius:8px;padding:16px;margin-bottom:16px">
          <p style="color:#FF6B35;margin:0 0 10px;font-size:12px;letter-spacing:1px">EVENT DETAILS</p>
          <p style="color:#F7F4EE;margin:0 0 6px;font-size:16px;font-weight:bold">${event.title}</p>
          <p style="color:#9A8F87;margin:0 0 4px;font-size:13px">📅 ${new Date(event.date).toDateString()}</p>
          <p style="color:#9A8F87;margin:0 0 4px;font-size:13px">⏰ ${event.time}</p>
          <p style="color:#9A8F87;margin:0;font-size:13px">📍 ${event.venue}, ${event.city}</p>
        </div>

        <!-- Payment details -->
        <div style="background:#262220;border-radius:8px;padding:16px;margin-bottom:24px">
          <p style="color:#FF6B35;margin:0 0 10px;font-size:12px;letter-spacing:1px">PAYMENT</p>
          <div style="display:flex;justify-content:space-between">
            <span style="color:#9A8F87;font-size:13px">${booking.seats} seat${booking.seats > 1 ? 's' : ''} × ₹${event.price}</span>
            <span style="color:#F7F4EE;font-size:13px">₹${booking.amount}</span>
          </div>
          ${booking.discount > 0 ? `
          <div style="display:flex;justify-content:space-between;margin-top:6px">
            <span style="color:#9A8F87;font-size:13px">Discount (${booking.couponCode})</span>
            <span style="color:#4CAF50;font-size:13px">- ₹${booking.discount}</span>
          </div>` : ''}
          <hr style="border:none;border-top:1px solid #332E2A;margin:10px 0">
          <div style="display:flex;justify-content:space-between">
            <span style="color:#F7F4EE;font-size:14px;font-weight:bold">Total Paid</span>
            <span style="color:#FF6B35;font-size:14px;font-weight:bold">₹${booking.finalAmount}</span>
          </div>
        </div>

        <p style="color:#9A8F87;font-size:12px;text-align:center;margin:0">
          Show your Booking ID or QR code at the venue entrance.<br>
          Thank you for booking with EventFi! 🙏
        </p>
      </div>
    </div>
  </body>
  </html>`;

  await transporter.sendMail({
    from:    `EventFi <${process.env.EMAIL_USER}>`,
    to,
    subject,
    html,
  });
};

module.exports = { sendBookingConfirmation };
