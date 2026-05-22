const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { User } = require('../models');
const { where } = require('sequelize');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'replace_this_secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

async function register({ name, email, phone, password, role }) {
  const existing = await findUserByEmail(email);
  if (existing) throw new Error('Email already in use');
  const user = await createUser({ name, email, phone, password, role });
  const token = generateToken({ user_id: user.user_id, email: user.email, role: user.role });
  return { user, token };
}

async function login({ email, password }) {
  const user = await findUserByEmail(email);
  if (!user || !user.password_hash) throw new Error('Invalid credentials');
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) throw new Error('Invalid credentials');
  const token = generateToken({ user_id: user.user_id, email: user.email, role: user.role });
  // remove sensitive data
  delete user.password_hash;
  return { user, token };
}

function generateToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

async function getUserById(id) {
  return findUserById(id);
}

async function createUser({ name, email, phone, password, role }) {
  const hashed = await bcrypt.hash(password, 10);
  const verifiedRole = await isValidRole(role);

  if (!verifiedRole) throw new Error(`Le role est invalide ${role}`);

  const user = await User.create({ name, email, phone, role, password_hash: hashed });
  return { user_id: user.user_id, name: user.name, email: user.email, phone: user.phone, role: user.role };
}

async function findUserByEmail(email) {
  const user = await User.findOne({ where: { email } });
  if (!user) return null;
  return user.get({ plain: true });
}

async function findUserById(id) {
    const user = await User.findByPk(id);
    return user ? user.get({ plain: true }) : null;
}

const VALID_ROLES = ['agent','admin','user'];

async function isValidRole(role){
    if (!role) return false;
    return VALID_ROLES.includes(role);
}
async function findUserById(id) {
    const user = await User.findByPk(id);
    return user ? user.get({ plain: true }) : null;
}

async function findAllClients(){
    const clients = await User.findAll({ where: { role: 'user' }, attributes: ['user_id', 'name', 'email', 'phone'] });
    return clients.map(c => c.get({ plain: true }));
}

async function findAllUsers(){
    const users = await User.findAll({ attributes: ['user_id', 'name', 'email', 'phone', 'role'] });
    return users.map(c => c.get({ plain: true }));
}

module.exports = { register, login, generateToken, getUserById, findAllClients, findAllUsers, findUserById };
