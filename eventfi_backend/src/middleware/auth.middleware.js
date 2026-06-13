const jwt = require('jsonwebtoken');
const { error } = require('../utils/response');

// ─── Protect — require valid JWT ────────────────────────────
exports.protect = (req, res, next) => {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json(error('Not authorized. Token missing.'));
  }

  const token = header.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id, role, iat, exp }
    next();
  } catch {
    return res.status(401).json(error('Not authorized. Invalid or expired token.'));
  }
};

// ─── Admin — must be role: 'admin' ──────────────────────────
exports.adminOnly = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json(error('Access denied. Admins only.'));
  }
  next();
};
