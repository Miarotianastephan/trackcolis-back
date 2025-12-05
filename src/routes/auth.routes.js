const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { requireAdmin } = require('../middleware/authorize.middleware');
const { authenticate } = require('../middleware/auth.middleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/clients', authenticate, requireAdmin, authController.getClients);

module.exports = router;
