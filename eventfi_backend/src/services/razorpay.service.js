const Razorpay = require('razorpay');
const crypto   = require('crypto');

const razorpay = new Razorpay({
  key_id:     process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

/// Create a Razorpay order — amount in rupees, converted to paise internally
const createOrder = async (amountInRupees) => {
  const order = await razorpay.orders.create({
    amount:   Math.round(amountInRupees * 100), // paise
    currency: 'INR',
    receipt:  `rcpt_${Date.now()}`,
  });
  return order;
};

/// Verify payment signature from Flutter callback
const verifySignature = (orderId, paymentId, signature) => {
  const body     = `${orderId}|${paymentId}`;
  const expected = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest('hex');
  return expected === signature;
};

/// Initiate refund on a payment
const refund = async (paymentId, amountInRupees) => {
  return razorpay.payments.refund(paymentId, {
    amount: Math.round(amountInRupees * 100),
  });
};

module.exports = { createOrder, verifySignature, refund };
