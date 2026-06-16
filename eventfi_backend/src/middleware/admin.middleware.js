/// Runs AFTER protect middleware — checks for admin role
const adminOnly = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Admin access required. Contact support to request admin privileges.',
    });
  }
  next();
};

module.exports = { adminOnly };
