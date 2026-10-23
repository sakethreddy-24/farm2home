// JWT middleware: checks the token and attaches req.user = { id, role }
const jwt = require('jsonwebtoken');

function verifyToken(req, res, next) {
  const header = req.headers['authorization'] || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ message: 'No token provided' });

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (e) {
    res.status(401).json({ message: 'Invalid or expired token' });
  }
}

// Allows only users with the given role (e.g. 'farmer')
function requireRole(role) {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return res.status(403).json({ message: `Only ${role}s can do this` });
    }
    next();
  };
}

module.exports = { verifyToken, requireRole };
