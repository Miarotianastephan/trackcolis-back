const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { requireAdmin } = require('../middleware/authorize.middleware');
const { authenticate } = require('../middleware/auth.middleware');

function requireSameUser(req, res, next) {
  const paramId = String(req.params.id);
  const tokenUserId = String(req.user.user_id);

  if (paramId !== tokenUserId) {
    return res.json({ user: null });
  }

  next();
}

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/clients', authenticate, requireAdmin, authController.getClients);
router.get('/users', authenticate, authController.getAllUsers);
router.get('/user/:id', authenticate, requireSameUser, authController.getUserById);
module.exports = router;
