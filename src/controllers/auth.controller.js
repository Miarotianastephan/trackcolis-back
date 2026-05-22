const authService = require('../services/auth.service');

// default role when none is provided
const DEFAULT_ROLE = 'user';

async function register(req, res, next) {
  try {
    const { name, email, phone, password, role } = req.body;
    const usedRole = role ? role : DEFAULT_ROLE;
    if (!name || !email || !password) return res.status(400).json({ error: 'Missing required fields' });
    const result = await authService.register({ name, email, phone, password, role: usedRole });
    res.status(201).json({ user: result.user, token: result.token });
  } catch (err) {
    if (err.message && err.message.includes('Email')) return res.status(409).json({ message: err.message });
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
    return res.status(401).json({ message: 'Invalid credentials' });
  }
}

// Récupérer la liste des clients (Admin only)
async function getClients(req, res, next) {
  try {
    const clients = await authService.findAllClients();
    res.json({ clients });
  } catch (err) {
    next(err);
  }
}
async function getUserById(req, res, next) {
  try {
    const { id } = req.params;
    const user = await authService.findUserById(id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  }
  catch (err) {
    next(err);
  }
}

async function getAllUsers(req, res, next) {
  try {
    const users = await authService.findAllUsers();
    res.json({ users });
  } catch (err) {
    next(err);
  }
}

module.exports = { register, login, getClients, getAllUsers, getUserById };
