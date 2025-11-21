const jwt = require('jsonwebtoken');
const authService = require('../services/auth.service');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'replace_this_secret';

async function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return res.status(401).json({ error: 'Unauthorized' });
  const token = header.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    console.log('Payllod Header: ', payload);
    const user = await authService.getUserById(payload.user_id);
    console.log('User Header: ', user);
    if (!user) return res.status(401).json({ error: 'Unauthorized' });
    req.user = { user_id: user.user_id, email: user.email, role_id: user.role_id };
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

module.exports = { authenticate };
