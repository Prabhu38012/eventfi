const QRCode = require('qrcode');

/// Generate a QR code data URL from a booking ID
const generate = async (bookingId) => {
  const dataUrl = await QRCode.toDataURL(bookingId, {
    width:  300,
    margin: 2,
    color:  { dark: '#1C1917', light: '#F7F4EE' },
    errorCorrectionLevel: 'H',
  });
  return dataUrl;
};

module.exports = { generate };
