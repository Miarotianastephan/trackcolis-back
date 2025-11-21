const authService = require('../services/auth.service');

const DEFAULT_ROLE_ID = 3 // Client utilisateur standard 

async function register(req, res, next) {
  try {
    const { name, email, phone, password, role_id } = req.body;
    const used_role = role_id ? role_id : DEFAULT_ROLE_ID
    console.log('role id'+used_role)
    if (!name || !email || !password) return res.status(400).json({ error: 'Missing required fields' });
    const result = await authService.register({ name, email, phone, password, role_id:used_role });
    res.status(201).json({ user: result.user, token: result.token });
  } catch (err) {
    if (err.message && err.message.includes('Email')) return res.status(409).json({ error: err.message });
    next(err);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'Missing credentials' });
    const result = await authService.login({ email, password });
    res.json({ user: result.user, token: result.token });
  } catch (err) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
}

module.exports = { register, login };
