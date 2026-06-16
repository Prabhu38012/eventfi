// ─────────────────────────────────────────────────────────────
//  Make Admin Utility
//  Usage: node src/utils/make_admin.js youremail@gmail.com
// ─────────────────────────────────────────────────────────────
const mongoose = require('mongoose');
const User     = require('../models/User');
require('dotenv').config();

const email = process.argv[2];

if (!email) {
  console.error('❌ Usage: node src/utils/make_admin.js youremail@gmail.com');
  process.exit(1);
}

mongoose.connect(process.env.MONGODB_URI).then(async () => {
  const user = await User.findOneAndUpdate(
    { email },
    { $set: { role: 'admin' } },
    { new: true }
  );
  if (user) {
    console.log(`✅ Success! ${email} is now an admin.`);
    console.log(`   Log out and log back in, then go to /admin`);
  } else {
    console.log(`❌ User not found: ${email}`);
    console.log(`   Make sure you have logged in to the app first.`);
  }
  process.exit(0);
}).catch(err => {
  console.error('❌ MongoDB error:', err.message);
  process.exit(1);
});
