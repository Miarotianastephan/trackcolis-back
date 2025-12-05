const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { User, UserRole } = require('../models');
const { where } = require('sequelize');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'replace_this_secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

async function register({ name, email, phone, password, role_id }) {
  const existing = await findUserByEmail(email);
  if (existing) throw new Error('Email already in use');
  const user = await createUser({ name, email, phone, password, role_id });
  const token = generateToken({ user_id: user.user_id, email: user.email, role_id: user.role_id });
  return { user, token };
}

async function login({ email, password }) {
  const user = await findUserByEmail(email);
  if (!user || !user.password_hash) throw new Error('Invalid credentials');
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) throw new Error('Invalid credentials');
  const token = generateToken({ user_id: user.user_id, email: user.email, role_id: user.role_id });
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

async function createUser({ name, email, phone, password, role_id }) {
  const hashed = await bcrypt.hash(password, 10);
  const verifiedRole = await isValidRole(role_id);

  if(verifiedRole == false) throw new Error(`Le role est invalide ${role_id}`);

  const user = await User.create({ name, email, phone, role_id, password_hash: hashed });
  return { user_id: user.user_id, name: user.name, email: user.email, phone: user.phone, role_id: user.role_id };
}

async function findUserByEmail(email) {
  const user = await User.findOne({ where: { email } });
  if (!user) return null;
  return user.get({ plain: true });
}

async function findUserById(id) {
    const user = await User.findByPk(id, { include: [{ model: UserRole, attributes: ['role_id','role_name'] }] });
    return user ? user.get({ plain: true }) : null;
}

async function isValidRole(role_id){
    console.log('Role '+role_id)
    if(!role_id) return false;
    const role_valid = UserRole.findByPk(role_id);
    if(!role_valid) return false;
    return true
}

async function findAllClients(){
    const clients = await User.findAll({ where: { role_id: 3 }, attributes: ['user_id', 'name', 'email', 'phone'] });
    return clients.map(c => c.get({ plain: true }));
}

module.exports = { register, login, generateToken, getUserById, findAllClients };
